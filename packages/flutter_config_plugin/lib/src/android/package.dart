library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

// ---------------------------------------------------------------------------
// withAndroidPackage
// ---------------------------------------------------------------------------

/// Set the applicationId in app/build.gradle and package in AndroidManifest.xml.
ConfigPlugin withAndroidPackage(String packageName) {
  return (config) {
    config = config.copyWith(applicationId: packageName);
    // Update build.gradle applicationId.
    config = withMod(
      config,
      platform: 'android',
      modName: 'appBuildGradle',
      action: (props) async {
        String contents = (props.modResults as String?) ?? '';
        contents = setApplicationId(contents, packageName);
        return props.copyWith(modResults: contents);
      },
    );
    // Update manifest package attribute.
    config = withMod(
      config,
      platform: 'android',
      modName: 'manifest',
      action: (props) async {
        final doc = props.modResults!;
        setAttribute(doc.rootElement, 'package', packageName);
        return props.copyWith(modResults: doc);
      },
    );
    return config;
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String setApplicationId(String gradle, String applicationId) {
  if (RegExp(r'applicationId\s+"').hasMatch(gradle)) {
    return gradle.replaceFirstMapped(
      RegExp(r'applicationId\s+"[^"]*"'),
      (_) => 'applicationId "$applicationId"',
    );
  }
  return gradle.replaceFirst(
    RegExp(r'(defaultConfig\s*\{)'),
    'defaultConfig {\n        applicationId "$applicationId"',
  );
}

String? getApplicationId(String gradle) {
  final match = RegExp(r'applicationId\s+"([^"]+)"').firstMatch(gradle);
  return match?[1];
}
