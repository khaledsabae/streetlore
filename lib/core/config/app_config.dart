import 'dart:convert';

class AppConfig {
  AppConfig._();
  static const String supabaseUrl = 'https://tbivoxyxclwjjspwsgvc.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRiaXZveHl4Y2x3ampzcHdzZ3ZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzMjA3NjMsImV4cCI6MjA5OTg5Njc2M30.uM9F6_O-ObiiVkF8hjQmsFovf3h4gTaode719u6bAnI';
  static const bool supabaseEnabled = true;

  static const String _dartDefineKeysBase64 =
      String.fromEnvironment('GEMINI_API_KEYS', defaultValue: '');

  static List<String> get geminiApiKeys {
    final dynamic dyn = _runtimeKeysAccessor?.call();
    if (dyn != null && dyn is List && dyn.isNotEmpty) {
      final typed = <String>[];
      for (final e in dyn) {
        if (e != null) {
          final s = e.toString();
          if (s.isNotEmpty) typed.add(s);
        }
      }
      if (typed.isNotEmpty) return List<String>.unmodifiable(typed);
    }
    if (_dartDefineKeysBase64.isEmpty) return const <String>[];
    final decoded = utf8.decode(base64.decode(_dartDefineKeysBase64));
    final fromBuild = decoded
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    return fromBuild;
  }

  static String get geminiApiKey {
    final keys = geminiApiKeys;
    return keys.isNotEmpty ? keys.first : '';
  }

  static List<String> Function()? _runtimeKeysAccessor;

  static void setRuntimeKeysForTest(List<String>? keys) {
    if (keys == null) {
      _runtimeKeysAccessor = null;
    } else {
      _runtimeKeysAccessor = () => keys;
    }
  }

  static const String geminiModel = 'gemini-3.8-flash';
  static const bool geminiEnabled = true;
  static const bool newFeaturesEnabled = true;
  static const int defaultGeofenceRadius = 500;

  static const String webRedirectUrl =
      'https://mohamedsabae50-prog.github.io/streetlore-web-app/';

  static const String mobileRedirectUrl =
      'io.supabase.streetlore://login-callback/';

  static const String privacyPolicyUrl =
      'https://github.com/mohamedsabae50-prog/streetlore/blob/main/docs/legal/privacy-policy.md';
}
