import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/app_config.dart';

/// Wrapper around the official `google_generative_ai` SDK with a 5-key
/// rotation fallback. v1.0.36 replaces the manual `dart:io` REST
/// client (which carried auth quirks and got a 404 NOT_FOUND on
/// `gemini-1.5-flash-latest`) with the official SDK call shape:
///
///   final model = GenerativeModel(model: 'gemini-1.5-flash',
///       apiKey: currentKey);
///   final response = await model.generateContent(
///       [Content.text(prompt)]);
///
/// The SDK uses the documented `x-goog-api-key` header
/// (NOT the URL `?key=` query form). On any failure that looks like
/// "this key is bad / exhausted" (401 / 403 / 429 / 5xx) the wrapper
/// transparently retries with the next key. Non-rotation status codes
/// (400 / 404) and empty responses surface immediately so we don't
/// burn quota on a misconfiguration.
///
/// Public surface (`generateContent` + `GeminiResult.isOk`) is the
/// same as v1.0.34/35, so `ai_service.dart` and
/// `ai_tour_guide_service.dart` need no changes.
class GeminiRestClient {
  GeminiRestClient._();
  static final GeminiRestClient instance = GeminiRestClient._();

  static const Duration _timeout = Duration(seconds: 45);

  /// v1.0.37 model fallback chain. Tried in order for EVERY key in
  /// the rotation; a 404 NOT_FOUND on one model name silently moves
  /// to the next name (same key, different model). The SDK still
  /// uses the official `x-goog-api-key` header auth + 5-key rotation
  /// on 401/403/429/5xx/timeouts; this list just adds a per-key
  /// model failover on top of that.
  ///
  /// v1.0.38: dropped `gemini-1.0-pro` from the chain. The user
  /// confirmed the live v1.0.37 build surfaced
  ///   `models/gemini-1.0-pro is not found for API version v1beta,
  ///    or is not supported for generateContent`
  /// into the chat bubble - the 1.0 line is not available on the
  /// v1beta endpoint. We now stick to the 1.5 family only:
  /// 1.5-flash-002 -> 1.5-flash-001 -> 1.5-flash. If all three
  /// still 404 / time out, the outer try-catch below returns a
  /// conversational "Sorry, I am currently unavailable." via the
  /// GeminiResult.text field with statusCode = 599 so the AI
  /// Tour Guide renders it directly in the chat bubble instead
  /// of the raw API crash log.
  ///
  /// The `model` argument from callers is prepended (deduped) so
  /// future callers can opt into a new model without changing this
  /// file.
  static const List<String> _modelFallbackOrder = [
    'gemini-1.5-flash-002',
    'gemini-1.5-flash-001',
    'gemini-1.5-flash',
  ];

  /// v1.0.38 sentinel status code surfaced to callers when ALL keys
  /// AND ALL models failed. The [GeminiResult.text] in this case
  /// contains a friendly fallback message that callers should
  /// display verbatim to the user (no further exception handling).
  static const int _friendlyFallbackStatus = 599;

  /// Base friendly fallback text shown in the AI Tour Guide chat
  /// bubble when all 5 keys × 3 models have failed. The v1.0.39
  /// build appends the last (key, model) HTTP status code in
  /// parentheses so the user can tell at a glance whether the
  /// failure was a 401/403 (key / quota / model issue) vs a 5xx
  /// (transient upstream). The full raw errorBody is still
  /// preserved on `GeminiResult.errorBody` for logcat debug.
  static const String _friendlyFallbackText =
      "Sorry, I am currently unavailable. Please try again in a moment.";

  /// Send a `generateContent` request.
  ///
  /// Returns the concatenated text of the first candidate, or a
  /// populated [GeminiResult] with the last error. Never throws —
  /// failures are logged and returned so callers can decide on their
  /// own fallback.
  ///
  /// If ALL 5 keys × 3 models fail, the wrapper returns a
  /// `GeminiResult` with `statusCode == 599` and `text ==`
  /// [_friendlyFallbackText]. Callers that want to surface that
  /// directly into the chat (no exception, no raw API log) check
  /// `result.statusCode == 599` and use `result.text` verbatim.
  ///
  /// If [apiKeys] (or [apiKey]) is null/empty, falls back to the
  /// keys defined in [AppConfig.geminiApiKeys].
  ///
  /// Failure handling:
  ///  - 401 / 403 / 429 / 5xx -> rotate to the next key
  ///  - 404 NOT_FOUND on a specific MODEL name -> rotate within the
  ///    [model] list using the same key
  ///  - 400 / "not found" + non-rotation status -> surface immediately
  ///  - network/timeout -> rotate to the next key
  Future<GeminiResult?> generateContent({
    String? apiKey,
    List<String>? apiKeys,
    required String model,
    required String systemInstruction,
    required String userPrompt,
    double temperature = 0.7,
    int maxOutputTokens = 1024,
  }) async {
    // Build the ordered key list. Prefer the explicit apiKey first
    // if provided, then the configured keys (deduped).
    final keys = <String>[];
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      keys.add(apiKey.trim());
    }
    if (apiKeys != null) {
      for (final k in apiKeys) {
        final t = k.trim();
        if (t.isNotEmpty && !keys.contains(t)) keys.add(t);
      }
    }
    for (final k in _configuredKeys) {
      if (!keys.contains(k)) keys.add(k);
    }
    if (keys.isEmpty) {
      debugPrintGemini('SDK call: no api keys available');
      return null;
    }

    // Build the ordered model list. The caller's `model` argument
    // goes first (if it's not already in the fallback chain) so a
    // future caller wanting a new model can opt in without a
    // client update.
    final models = <String>[model];
    for (final m in _modelFallbackOrder) {
      if (!models.contains(m)) models.add(m);
    }

    final body = '$systemInstruction\n\n$userPrompt';

    GeminiResult? lastResult;
    try {
      keyLoop:
      for (var ki = 0; ki < keys.length; ki++) {
      final key = keys[ki];
      final keyRedacted = key.length > 8
          ? '${key.substring(0, 4)}...${key.substring(key.length - 4)}'
          : '****';
      for (var mi = 0; mi < models.length; mi++) {
        final tryModel = models[mi];
        debugPrintGemini(
          'SDK call: model=$tryModel key=$keyRedacted '
          'keyAttempt=${ki + 1}/${keys.length} '
          'modelAttempt=${mi + 1}/${models.length}',
        );
        try {
          final m = GenerativeModel(
            model: tryModel,
            apiKey: key,
            generationConfig: GenerationConfig(
              temperature: temperature,
              maxOutputTokens: maxOutputTokens,
            ),
          );
          final response = await m
              .generateContent([Content.text(body)])
              .timeout(_timeout);
          final text = response.text;
          if (text == null || text.isEmpty) {
            debugPrintGemini(
              'SDK call: 200 but empty text on '
              'key #${ki + 1}, model=$tryModel',
            );
            // Empty success is a content issue, not a key / model
            // issue — surface it to the caller immediately so it can
            // fall back to a local response.
            return const GeminiResult(
              text: null,
              statusCode: 200,
              errorBody: 'empty text',
              raw: null,
            );
          }
          return GeminiResult(
            text: text,
            statusCode: 200,
            errorBody: null,
            raw: null,
          );
        } on InvalidApiKey catch (e) {
          // 401-class — that KEY is dead; try the next key with the
          // same model list reset.
          debugPrintGemini(
            'SDK call: InvalidApiKey on key #${ki + 1}, '
            'model=$tryModel: ${e.message}',
          );
          lastResult = GeminiResult(
            text: null,
            statusCode: 401,
            errorBody: e.message,
            raw: null,
          );
          continue keyLoop; // skip remaining models for this key
        } on UnsupportedUserLocation catch (e) {
          // 403-class — same treatment.
          debugPrintGemini(
            'SDK call: UnsupportedUserLocation on key #${ki + 1}, '
            'model=$tryModel: ${e.message}',
          );
          lastResult = GeminiResult(
            text: null,
            statusCode: 403,
            errorBody: e.message,
            raw: null,
          );
          continue keyLoop;
        } on ServerException catch (e) {
          final status = _classifyExceptionMessage(e.message);
          debugPrintGemini(
            'SDK call: ServerException on key #${ki + 1}, '
            'model=$tryModel (status=$status): ${e.message}',
          );
          lastResult = GeminiResult(
            text: null,
            statusCode: status,
            errorBody: e.message,
            raw: null,
          );
          if (status == 404) {
            // ============================================================
            // v1.0.37 RADICAL FIX: 404 means "this MODEL is unavailable
            // for this API version" - NOT a key failure. Drop to the
            // next model in the chain with the SAME key before burning
            // the key.
            // ============================================================
            debugPrintGemini(
              'SDK call: model $tryModel 404 on key #${ki + 1}, '
              'trying next model name with same key',
            );
            continue; // try next model
          }
          if (status > 0 && !_shouldRotateKey(status)) {
            debugPrintGemini(
              'SDK call: non-rotation status $status on key '
              '#${ki + 1}, model=$tryModel, surfacing without '
              'burning more keys',
            );
            return lastResult;
          }
          // Rotation status (429/5xx): break out of inner loop and
          // try the next key.
          continue keyLoop;
        } on GenerativeAIException catch (e) {
          // 5xx-style: SDK throws `GenerativeAIException('Server
          // Error [500]: ...')`. Status code parsed out of message.
          final status = _parseStatusFromMessage(e.message);
          debugPrintGemini(
            'SDK call: GenerativeAIException on key #${ki + 1}, '
            'model=$tryModel (status=$status): ${e.message}',
          );
          lastResult = GeminiResult(
            text: null,
            statusCode: status,
            errorBody: e.message,
            raw: null,
          );
          if (status > 0 && !_shouldRotateKey(status)) {
            return lastResult;
          }
          continue keyLoop;
        } on GenerativeAISdkException catch (e) {
          // SDK has a stale package version / implementation bug.
          // Surface immediately so the user sees something actionable
          // in logcat.
          debugPrintGemini(
            'SDK call: GenerativeAISdkException on key #${ki + 1}, '
            'model=$tryModel: $e',
          );
          lastResult = GeminiResult(
            text: null,
            statusCode: 0,
            errorBody: e.message,
            raw: null,
          );
          return lastResult;
        } on TimeoutException {
          debugPrintGemini(
            'SDK call: timeout on key #${ki + 1}, '
            'model=$tryModel',
          );
          lastResult = const GeminiResult(
            text: null,
            statusCode: 0,
            errorBody: 'timeout',
            raw: null,
          );
          // Timeout could be a key issue or a network issue;
          // rotate to next key.
          continue keyLoop;
        } catch (e) {
          debugPrintGemini(
            'SDK call: unknown exception on key #${ki + 1}, '
            'model=$tryModel: $e',
          );
          lastResult = GeminiResult(
            text: null,
            statusCode: 0,
            errorBody: e.toString(),
            raw: null,
          );
          continue keyLoop;
        }
      }
    }
    } catch (e, st) {
      // Outer catch: catches any SDK exception or unexpected error
      // that slipped past the per-attempt handlers above. The inner
      // loops already turned every per-attempt error into a
      // `lastResult` (or surfaced it) so reaching this catch usually
      // means the request pipeline blew up (e.g. socket closed mid
      // loop). Fall through to the friendly fallback below.
      debugPrintGemini('SDK call: outer catch: $e\n$st');
      lastResult ??= GeminiResult(
        text: null,
        statusCode: 0,
        errorBody: e.toString(),
        raw: null,
      );
    }
    // ============================================================
    // v1.0.38: when every (key, model) attempt has failed, return
    // a friendly fallback text + the sentinel statusCode 599 so
    // the AI Tour Guide can render the friendly message directly
    // in the chat bubble instead of dumping the raw API crash log
    // into it. Callers that want the raw last error can still read
    // `lastResult?.errorBody`.
    // ============================================================
    // v1.0.39: append the last HTTP status code to the friendly
    // text so the user can tell whether it's a 401/403 (auth /
    // quota / wrong model) or a 5xx (transient upstream) or a
    // network error (status 0). We only include the code if it's
    // a recognised status - otherwise the user just sees the
    // base message and the full errorBody is preserved on the
    // result for logcat.
    final lastStatus = lastResult?.statusCode ?? 0;
    final friendlyText = lastStatus > 0 && lastStatus != _friendlyFallbackStatus
        ? '$_friendlyFallbackText (Error: $lastStatus)'
        : _friendlyFallbackText;
    debugPrintGemini(
      'SDK call: ALL ${keys.length}x${models.length} attempts failed; '
      'last status=$lastStatus, last errorBody=${lastResult?.errorBody}',
    );
    return GeminiResult(
      text: friendlyText,
      statusCode: _friendlyFallbackStatus,
      errorBody: lastResult?.errorBody ??
          'all ${keys.length} keys x ${models.length} models failed',
      raw: null,
    );
  }

  /// Pull the HTTP status code out of an SDK exception message.
  /// - For 5xx the SDK formats the string as `Server Error [500]: ...`
  ///   so the regex catches it.
  /// - For 4xx the SDK just hands us the JSON `error.message` (often
  ///   `models/gemini-1.5-flash is not found for API version v1beta`),
  ///   so we inspect the text to detect the most common cases:
  ///     "not found" -> 404, "quota" / "rate" -> 429, "API key" -> 401
  ///   Anything else falls through as 0 (rotate-on-failure).
  int _classifyExceptionMessage(String message) {
    final fromBrackets = _parseStatusFromMessage(message);
    if (fromBrackets > 0) return fromBrackets;
    final lower = message.toLowerCase();
    if (lower.contains('not found') ||
        lower.contains('no longer available') ||
        lower.contains('is not supported')) {
      return 404;
    }
    if (lower.contains('quota') ||
        lower.contains('rate') ||
        lower.contains('too many requests') ||
        lower.contains('resource_exhausted')) {
      return 429;
    }
    if (lower.contains('api key') || lower.contains('permission')) {
      return 401;
    }
    return 0;
  }

  /// Parse `[NNN]` out of a message like `Server Error [500]: ...`.
  int _parseStatusFromMessage(String message) {
    final m = RegExp(r'\[(\d{3})\]').firstMatch(message);
    if (m == null) return 0;
    return int.tryParse(m.group(1) ?? '') ?? 0;
  }

  /// v1.0.34 spec: 401 / 403 / 429 / 5xx rotate; 400 / 404 (and any
  /// 0-status unknown) rotate-on-network-failure.
  bool _shouldRotateKey(int statusCode) {
    if (statusCode == 401 || statusCode == 403 || statusCode == 429) {
      return true;
    }
    if (statusCode >= 500 && statusCode < 600) return true;
    if (statusCode == 0) return true; // network/timeout
    return false;
  }

  /// Keys from AppConfig, evaluated lazily so tests / build time tools
  /// can override them.
  List<String> get _configuredKeys =>
      _configKeysAccessor?.call() ??
      AppConfig.geminiApiKeys.toList(growable: false);

  /// Indirection hook so we can swap out the key source in tests.
  static List<String> Function()? _configKeysAccessor;

  /// Test hook: replace the key source (e.g. with an in-memory list).
  static void setConfigKeysAccessorForTest(List<String> Function()? f) {
    _configKeysAccessor = f;
  }
}

class GeminiResult {
  final String? text;
  final int statusCode;
  final String? errorBody;
  final String? raw;
  const GeminiResult({
    required this.text,
    required this.statusCode,
    required this.errorBody,
    required this.raw,
  });
  bool get isOk => text != null && (statusCode == 200 || statusCode == 201);
}

void debugPrintGemini(String msg) {
  // ignore: avoid_print
  print('[GeminiRestClient] $msg');
}
