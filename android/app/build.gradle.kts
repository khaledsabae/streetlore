import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from android/key.properties (local, git-ignored)
// or from environment variables (CI). Nothing secret lives in this file.
//   storeFile=release_v2.keystore
//   storePassword=...
//   keyAlias=streetlore
//   keyPassword=...
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
fun signingValue(prop: String, env: String): String? =
    (keystoreProperties.getProperty(prop) ?: System.getenv(env))?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("storeFile", "STREETLORE_KEYSTORE_FILE") ?: "release_v2.keystore"
val releaseStorePassword = signingValue("storePassword", "STREETLORE_KEYSTORE_PASSWORD")
val releaseKeyAlias = signingValue("keyAlias", "STREETLORE_KEY_ALIAS") ?: "streetlore"
val releaseKeyPassword = signingValue("keyPassword", "STREETLORE_KEY_PASSWORD")
val hasReleaseSigning = releaseStorePassword != null && releaseKeyPassword != null &&
    file(releaseStoreFile).exists()

android {
    namespace = "com.streetlore.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // تم إضافة السطر ده هنا
    }

    defaultConfig {
        // Final Play Store id. Changing it later means a brand-new app listing.
        applicationId = "com.streetlore.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Without key.properties / env vars (e.g. a contributor's
            // machine) release builds fall back to debug signing; CI
            // verifies the real certificate before publishing.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // v1.0.29: R8 / ProGuard disabled. v1.0.28 turned on
            // minify + resource shrinking which apparently stripped
            // some Google Sign-In / Supabase native class the
            // reflection-based plugin needs at runtime, surfacing
            // as a Code 10 in the user's installation. Reverting to
            // the v1.0.27 build configuration keeps the native
            // entry points intact.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}