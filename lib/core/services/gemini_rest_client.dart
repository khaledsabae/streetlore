import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Thin client for the `ai-proxy` Supabase Edge Function
/// (supabase/functions/ai-proxy).
///
/// The app holds NO Gemini key. The function keeps a single server-side
/// key, requires a signed-in user, enforces a per-user daily quota and
/// caps prompt / output sizes.
class GeminiRestClient {
  GeminiRestClient._();
  static final GeminiRestClient instance = GeminiRestClient._();

  static const String _functionName = 'ai-proxy';
  static const Duration _timeout = Duration(seconds: 45);

  /// True when a live AI call can be attempted: AI is enabled and the user
  /// is signed in with a real (non-guest) Supabase session.
  bool get isAvailable {
    if (!AppConfig.geminiEnabled || !AppConfig.supabaseEnabled) return false;
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  /// Returns null when AI is not available (disabled / signed out).
  /// `model` is ignored — the server decides the model.
  Future<GeminiResult?> generateContent({
    String? model,
    required String systemInstruction,
    required String userPrompt,
    double temperature = 0.7,
    int maxOutputTokens = 1024,
  }) async {
    if (!isAvailable) return null;
    try {
      final res = await Supabase.instance.client.functions
          .invoke(
            _functionName,
            body: {
              'system': systemInstruction,
              'prompt': userPrompt,
              'temperature': temperature,
              'maxOutputTokens': maxOutputTokens,
            },
          )
          .timeout(_timeout);
      final data = res.data;
      final text = data is Map ? data['text'] as String? : null;
      if (text == null || text.trim().isEmpty) {
        return GeminiResult(
          text: null,
          statusCode: res.status,
          errorBody: 'empty text',
          raw: null,
        );
      }
      return GeminiResult(
        text: text,
        statusCode: res.status,
        errorBody: null,
        raw: null,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map ? details['error'] as String? : null;
      debugPrint('[GeminiRestClient] ai-proxy ${e.status} ${code ?? ''}');
      return GeminiResult(
        text: null,
        statusCode: e.status,
        errorBody: code ?? 'ai_proxy_error',
        raw: null,
      );
    } on TimeoutException {
      debugPrint('[GeminiRestClient] ai-proxy timeout');
      return const GeminiResult(
        text: null,
        statusCode: 504,
        errorBody: 'timeout',
        raw: null,
      );
    } catch (e) {
      debugPrint('[GeminiRestClient] ai-proxy failed: $e');
      return const GeminiResult(
        text: null,
        statusCode: 0,
        errorBody: 'network',
        raw: null,
      );
    }
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
