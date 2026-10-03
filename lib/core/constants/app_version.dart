/// Single source of truth for the app version displayed in the UI.
///
/// Bump this whenever you tag a release. The CI workflow (`release.yml`)
/// tags v1.x.y from main and bumps `pubspec.yaml` to that same version;
/// keep these two numbers in sync so the About screen and the version
/// helper both show the correct value.
///
/// The build number (`+NN`) is the Android versionCode / iOS build
/// number; the version string (`1.x.y`) is the human-readable name.
const String kAppVersion = '1.0.62';
const String kAppBuildNumber = '63';
const String kAppVersionFull = '$kAppVersion+$kAppBuildNumber';

/// Human-friendly label for the About screen.
String formatAppVersionLabel() => 'Version $kAppVersionFull';