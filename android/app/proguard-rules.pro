# ============================================================
# StreetLore - ProGuard / R8 rules
# ============================================================
# R8 (the default code shrinker in AGP 7+) reads this file via
# `proguardFiles(...)` in app/build.gradle.kts. The Flutter Gradle
# plugin already injects the rules it needs, but a few plugin
# integrations require us to keep their reflection / JNI entry
# points or R8 strips them and the app crashes at runtime.

# Keep our application class (default behaviour, but explicit).
-keep class com.streetlore.app.** { *; }

# Flutter / Dart embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Supabase / gotrue (Kotlin coroutines + JWT)
-keep class io.github.jaswon** { *; }
-keep class io.supabase.** { *; }
-keep class io.gotrue.** { *; }
-keepclassmembers class kotlinx.coroutines.** { volatile <fields>; }
-dontwarn kotlinx.coroutines.**
-dontwarn org.jetbrains.annotations.**

# google_sign_in plugin (used by AuthProvider for native Google flow)
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.api.client.** { *; }
-dontwarn com.google.android.gms.**

# Cached network image (uses reflection on platform plugins)
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# flutter_local_notifications (geofence alerts)
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Reanimated / Rive / Lottie (used in onboarding / splash / profile)
-keep class com.rive.** { *; }
-keep class com.airbnb.lottie.** { *; }

# Geolocator / flutter_map (TileLayer uses HTTP headers via dart:io)
-dontwarn com.lyokone.location.**

# OkHttp / Cronet / dart:io (for HTTPS calls)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Strip log calls in release to shave a few KB and remove sensitive paths.
-assumenosideeffects class android.util.Log {
    public static int d(...);
    public static int v(...);
    public static int i(...);
}

# Keep line numbers for stack traces; rename source file for size.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ============================================================
# Play Core (deferred components) - referenced by the Flutter
# embedding but we don't ship the Play Core AAR. R8 sees the
# references and aborts the build; tell it to ignore them.
# ============================================================
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
