// ignore_for_file: avoid_print

import 'package:flutter_config_plugin/flutter_config_plugin.dart';

/// Demonstrates both usage styles:
///
/// **Style 1 (recommended):** YAML-driven via [withGenericConfig].
/// Declare everything in `flutter_config.yaml` + `.env` — no Dart code needed.
///
/// **Style 2:** Dart API via individual `withXxx()` functions.
/// Use when you need dynamic logic that YAML cannot express.
///
/// Run from the package root:
///   dart example/main.dart
Future<void> main() async {
  // ── Style 1: YAML-driven (recommended) ───────────────────────────────────
  //
  // In practice you just run the CLI:
  //   dart run flutter_config_plugin:flutter_config path/to/app
  //
  // The CLI reads flutter_config.yaml + .env and calls withGenericConfig
  // internally. Everything below is what happens under the hood.

  var config = const FlutterConfig(
    name: 'My App',
    bundleIdentifier: 'com.example.myapp',
    applicationId: 'com.example.myapp',
    version: '1.0.0',
  );

  // withGenericConfig mirrors the flutter_config.yaml `generic:` section.
  config = withGenericConfig({
    'ios': {
      'infoPlist': {
        'API_URL': 'https://api.example.com',
        'GOOGLE_MAPS_API_KEY': 'YOUR_KEY',
        'CADisableMinimumFrameDurationOnPhone': true,
      },
      'permissions': {
        'NSCameraUsageDescription': '"My App" needs camera access.',
        'NSLocationWhenInUseUsageDescription': '"My App" needs location.',
        'NSLocationAlwaysAndWhenInUseUsageDescription':
            '"My App" needs background location.',
        'NSPhotoLibraryUsageDescription': 'My App needs photo library access.',
      },
      'backgroundModes': ['location', 'fetch', 'remote-notification'],
      'urlSchemes': [
        {
          'role': 'Editor',
          'schemes': ['com.googleusercontent.apps.YOUR_CLIENT_ID'],
        },
      ],
    },
    'android': {
      'permissions': [
        'android.permission.INTERNET',
        'android.permission.CAMERA',
        'android.permission.ACCESS_FINE_LOCATION',
        {'name': 'android.permission.READ_EXTERNAL_STORAGE', 'maxSdkVersion': 32},
      ],
      'manifest': {
        'application': {
          'meta-data': [
            {'name': 'com.google.android.geo.API_KEY', 'value': 'YOUR_KEY'},
          ],
        },
      },
    },
  })(config);

  // ── Execute ───────────────────────────────────────────────────────────────
  print('Applying config to: /path/to/your/flutter/project');
  await compileModsAsync(
    config,
    const CompileModsOptions(
      projectRoot: '/path/to/your/flutter/project',
    ),
  );

  print('Done. Native files updated:');
  print('  • ios/Runner/Info.plist');
  print('  • android/app/src/main/AndroidManifest.xml');
}
