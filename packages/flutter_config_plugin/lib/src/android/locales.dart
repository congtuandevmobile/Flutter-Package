library;

import 'dart:io';
import 'package:path/path.dart' as p;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withAndroidLocales
// ---------------------------------------------------------------------------

/// Add supported locales to resConfigs in app/build.gradle and create
/// values-<locale>/strings.xml files.
///
/// [locales]: map of locale code → map of string key → translated value.
/// e.g. `{ 'fr': { 'app_name': 'Mon App' } }`
ConfigPlugin withAndroidLocales(Map<String, Map<String, String>> locales) {
  return (config) {
    // 1. Add resConfigs to build.gradle.
    config = withMod(
      config,
      platform: 'android',
      modName: 'appBuildGradle',
      action: (props) async {
        String contents = (props.modResults as String?) ?? '';
        for (final locale in locales.keys) {
          contents = _addResConfig(contents, locale);
        }
        return props.copyWith(modResults: contents);
      },
    );

    // 2. Write locale strings files via dangerous mod.
    config = withMod(
      config,
      platform: 'android',
      modName: 'dangerous',
      action: (props) async {
        if (props.modRequest.introspect) return props;
        await _writeLocaleFiles(
            props.modRequest.platformProjectRoot, locales);
        return props;
      },
    );

    return config;
  };
}

String _addResConfig(String gradle, String locale) {
  if (gradle.contains('"$locale"')) return gradle;
  if (RegExp(r'resConfigs\s+').hasMatch(gradle)) {
    return gradle.replaceFirstMapped(
      RegExp(r'(resConfigs\s+[^)]+)'),
      (m) => '${m[0]}, "$locale"',
    );
  }
  return gradle.replaceFirstMapped(
    RegExp(r'(defaultConfig\s*\{)'),
    (m) => '${m[0]}\n        resConfigs "$locale"',
  );
}

Future<void> _writeLocaleFiles(
    String androidRoot, Map<String, Map<String, String>> locales) async {
  for (final entry in locales.entries) {
    final locale = entry.key;
    final strings = entry.value;

    final resDir = Directory(
        p.join(androidRoot, 'app', 'src', 'main', 'res', 'values-$locale'));
    if (!resDir.existsSync()) resDir.createSync(recursive: true);

    final stringsFile = File(p.join(resDir.path, 'strings.xml'));
    final buf = StringBuffer(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n');
    for (final kv in strings.entries) {
      buf.writeln('    <string name="${kv.key}">${kv.value}</string>');
    }
    buf.write('</resources>');
    await stringsFile.writeAsString(buf.toString());
  }
}
