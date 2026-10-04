class AppConfig {
  AppConfig._();
  static const String supabaseUrl = 'https://tbivoxyxclwjjspwsgvc.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRiaXZveHl4Y2x3ampzcHdzZ3ZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzMjA3NjMsImV4cCI6MjA5OTg5Njc2M30.uM9F6_O-ObiiVkF8hjQmsFovf3h4gTaode719u6bAnI';
  static const bool supabaseEnabled = true;

  // The Gemini key and model live server-side in the ai-proxy Edge
  // Function (supabase/functions/ai-proxy). Never ship a key in the app.
  static const bool geminiEnabled = true;
  static const bool newFeaturesEnabled = true;
  static const int defaultGeofenceRadius = 500;

  static const String webRedirectUrl =
      'https://mohamedsabae50-prog.github.io/streetlore-web-app/';

  static const String mobileRedirectUrl =
      'io.supabase.streetlore://login-callback/';
}
