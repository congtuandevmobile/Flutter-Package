library;

import 'dart:io';

import '../types.dart';
import '../with_mod.dart';
import 'properties.dart';
import 'paths.dart';

// ---------------------------------------------------------------------------
// withAndroidBuildProperties
// ---------------------------------------------------------------------------

/// Set key-value pairs in android/gradle.properties.
ConfigPlugin withAndroidBuildProperties(Map<String, String> properties) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'gradleProperties',
        action: (props) async {
          var items = (props.modResults as List<PropertiesItem>?) ?? [];
          for (final entry in properties.entries) {
            items = setProperty(items, entry.key, entry.value);
          }
          return props.copyWith(modResults: items);
        },
      );
}

/// Pre-built plugin: enable/disable Hermes JS engine.
ConfigPlugin withHermesEnabled({required bool enabled}) =>
    withAndroidBuildProperties({'hermesEnabled': enabled.toString()});

/// Pre-built plugin: set min SDK version in gradle.properties.
ConfigPlugin withAndroidMinSdkVersion(int version) =>
    withAndroidBuildProperties({'minSdkVersion': version.toString()});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<List<PropertiesItem>> readGradleProperties(String androidRoot) async {
  final file = File(getGradlePropertiesPath(androidRoot));
  if (!file.existsSync()) return [];
  return parsePropertiesFile(await file.readAsString());
}

Future<void> writeGradleProperties(
    String androidRoot, List<PropertiesItem> items) async {
  final file = File(getGradlePropertiesPath(androidRoot));
  await file.writeAsString(propertiesListToString(items));
}
