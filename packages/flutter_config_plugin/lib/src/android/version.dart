library;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withAndroidVersion
// ---------------------------------------------------------------------------

/// Set versionName and versionCode in app/build.gradle.
ConfigPlugin withAndroidVersion({
  required String versionName,
  required int versionCode,
}) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'appBuildGradle',
        action: (props) async {
          String contents = (props.modResults as String?) ?? '';
          contents = setVersionName(contents, versionName);
          contents = setVersionCode(contents, versionCode);
          return props.copyWith(modResults: contents);
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String setVersionName(String gradle, String versionName) {
  if (RegExp(r'versionName\s+"').hasMatch(gradle)) {
    return gradle.replaceFirstMapped(
      RegExp(r'versionName\s+"[^"]*"'),
      (_) => 'versionName "$versionName"',
    );
  }
  return gradle.replaceFirst(
    RegExp(r'(defaultConfig\s*\{)'),
    'defaultConfig {\n        versionName "$versionName"',
  );
}

String setVersionCode(String gradle, int versionCode) {
  if (RegExp(r'versionCode\s+\d+').hasMatch(gradle)) {
    return gradle.replaceFirstMapped(
      RegExp(r'versionCode\s+\d+'),
      (_) => 'versionCode $versionCode',
    );
  }
  return gradle.replaceFirst(
    RegExp(r'(defaultConfig\s*\{)'),
    'defaultConfig {\n        versionCode $versionCode',
  );
}

String? getVersionName(String gradle) {
  final match = RegExp(r'versionName\s+"([^"]+)"').firstMatch(gradle);
  return match?[1];
}

int? getVersionCode(String gradle) {
  final match = RegExp(r'versionCode\s+(\d+)').firstMatch(gradle);
  final val = match?[1];
  return val != null ? int.tryParse(val) : null;
}
