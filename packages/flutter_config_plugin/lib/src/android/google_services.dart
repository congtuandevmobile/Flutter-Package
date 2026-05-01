library;

import 'dart:io';
import 'package:path/path.dart' as p;

import '../types.dart';
import '../with_mod.dart';
import '../utils/warnings.dart';

const _googleServicesClassPath = 'com.google.gms:google-services';
const _googleServicesPlugin = 'com.google.gms.google-services';
const _googleServicesVersion = '4.4.1';

// ---------------------------------------------------------------------------
// withGoogleServicesFile
// ---------------------------------------------------------------------------

/// Copy google-services.json into android/app and add the Google Services
/// Gradle plugin to build.gradle files.
///
/// [sourcePath]: path relative to the project root.
ConfigPlugin withGoogleServicesFile([String sourcePath = 'google-services.json']) {
  return (config) {
    // 1. Copy json file via dangerous mod.
    config = withMod(
      config,
      platform: 'android',
      modName: 'dangerous',
      action: (props) async {
        if (props.modRequest.introspect) return props;
        final src = File(p.join(props.modRequest.projectRoot, sourcePath));
        final dst = File(p.join(props.modRequest.platformProjectRoot, 'app', 'google-services.json'));
        if (src.existsSync()) {
          dst.parent.createSync(recursive: true);
          await src.copy(dst.path);
        } else {
          addWarningAndroid('googleServicesFile',
              'google-services.json not found at $sourcePath');
        }
        return props;
      },
    );

    // 2. Add classpath to project build.gradle.
    config = withMod(
      config,
      platform: 'android',
      modName: 'projectBuildGradle',
      action: (props) async {
        String contents = (props.modResults as String?) ?? '';
        contents = _addClassPath(contents);
        return props.copyWith(modResults: contents);
      },
    );

    // 3. Apply plugin in app/build.gradle.
    config = withMod(
      config,
      platform: 'android',
      modName: 'appBuildGradle',
      action: (props) async {
        String contents = (props.modResults as String?) ?? '';
        contents = _applyPlugin(contents);
        return props.copyWith(modResults: contents);
      },
    );

    return config;
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _addClassPath(String buildGradle) {
  if (buildGradle.contains(_googleServicesClassPath)) return buildGradle;
  return buildGradle.replaceFirstMapped(
    RegExp(r'dependencies\s*\{'),
    (m) =>
        "dependencies {\n        classpath '$_googleServicesClassPath:$_googleServicesVersion'",
  );
}

String _applyPlugin(String appBuildGradle) {
  final pattern =
      RegExp("apply\\s+plugin:\\s+['\"]$_googleServicesPlugin['\"]");
  if (appBuildGradle.contains(pattern)) return appBuildGradle;
  return "$appBuildGradle\napply plugin: '$_googleServicesPlugin'";
}
