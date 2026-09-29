import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/app_config.dart';

class GeminiRestClient {
  GeminiRestClient._();
  static final GeminiRestClient instance = GeminiRestClient._();

  static const Duration _timeout = Duration(seconds: 45);

  static const List<String> _modelFallbackOrder = [
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
  ];

  static const int _friendlyFallbackStatus = 599;

  static const String _friendlyFallbackText =
      "Sorry, I am currently unavailable. Please try again in a moment.";

  Future<GeminiResult?> generateContent({
    String? apiKey,
    List<String>? apiKeys,
    required String model,
    required String systemInstruction,
    required String userPrompt,
    double temperature = 0.7,
    int maxOutputTokens = 1024,
  }) async {
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
            continue keyLoop;
          } on UnsupportedUserLocation catch (e) {
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
              debugPrintGemini(
                'SDK call: model $tryModel 404 on key #${ki + 1}, '
                'trying next model name with same key',
              );
              continue;
            }
            if (status > 0 && !_shouldRotateKey(status)) {
              debugPrintGemini(
                'SDK call: non-rotation status $status on key '
                '#${ki + 1}, model=$tryModel, surfacing without '
                'burning more keys',
              );
              return lastResult;
            }

            continue keyLoop;
          } on GenerativeAIException catch (e) {
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
      debugPrintGemini('SDK call: outer catch: $e\n$st');
      lastResult ??= GeminiResult(
        text: null,
        statusCode: 0,
        errorBody: e.toString(),
        raw: null,
      );
    }

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
      errorBody:
          lastResult?.errorBody ??
          'all ${keys.length} keys x ${models.length} models failed',
      raw: null,
    );
  }

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

  int _parseStatusFromMessage(String message) {
    final m = RegExp(r'\[(\d{3})\]').firstMatch(message);
    if (m == null) return 0;
    return int.tryParse(m.group(1) ?? '') ?? 0;
  }

  bool _shouldRotateKey(int statusCode) {
    if (statusCode == 401 || statusCode == 403 || statusCode == 429) {
      return true;
    }
    if (statusCode >= 500 && statusCode < 600) return true;
    if (statusCode == 0) return true;
    return false;
  }

  List<String> get _configuredKeys =>
      _configKeysAccessor?.call() ??
      AppConfig.geminiApiKeys.toList(growable: false);

  static List<String> Function()? _configKeysAccessor;

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
  print('[GeminiRestClient] $msg');
}
