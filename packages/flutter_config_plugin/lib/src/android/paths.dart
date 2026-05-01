library;

import 'package:path/path.dart' as p;

/// Locate AndroidManifest.xml.
String getAndroidManifestPath(String androidRoot) =>
    p.join(androidRoot, 'app', 'src', 'main', 'AndroidManifest.xml');

/// Locate app/build.gradle.
String getAppBuildGradlePath(String androidRoot) =>
    p.join(androidRoot, 'app', 'build.gradle');

/// Locate root build.gradle.
String getProjectBuildGradlePath(String androidRoot) =>
    p.join(androidRoot, 'build.gradle');

/// Locate settings.gradle.
String getSettingsGradlePath(String androidRoot) =>
    p.join(androidRoot, 'settings.gradle');

/// Locate gradle.properties.
String getGradlePropertiesPath(String androidRoot) =>
    p.join(androidRoot, 'gradle.properties');

/// Locate strings.xml.
String getStringsXmlPath(String androidRoot) =>
    p.join(androidRoot, 'app', 'src', 'main', 'res', 'values', 'strings.xml');

/// Locate colors.xml.
String getColorsXmlPath(String androidRoot) =>
    p.join(androidRoot, 'app', 'src', 'main', 'res', 'values', 'colors.xml');

/// Locate styles.xml.
String getStylesXmlPath(String androidRoot) =>
    p.join(androidRoot, 'app', 'src', 'main', 'res', 'values', 'styles.xml');

/// Locate MainActivity.kt or .java.
String? getMainActivityPath(String androidRoot, String packageName) {
  final packagePath = packageName.replaceAll('.', '/');
  // Prefer Kotlin; callers can check existence and fall back to .java.
  return p.join(androidRoot, 'app', 'src', 'main', 'kotlin', packagePath, 'MainActivity.kt');
}
