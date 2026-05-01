library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../types.dart';
import '../utils/xml_utils.dart';
import 'properties.dart';

/// Register Android file-provider base mods onto [config].
FlutterConfig withAndroidBaseMods(FlutterConfig config, String projectRoot) {
  config = _withManifestBaseMod(config);
  config = _withStringsBaseMod(config);
  config = _withColorsBaseMod(config);
  config = _withAppBuildGradleBaseMod(config);
  config = _withProjectBuildGradleBaseMod(config);
  config = _withSettingsGradleBaseMod(config);
  config = _withGradlePropertiesBaseMod(config);
  config = _withDangerousBaseMod(config);
  return config;
}

// ---------------------------------------------------------------------------
// AndroidManifest.xml  (XmlDocument)
// ---------------------------------------------------------------------------

FlutterConfig _withManifestBaseMod(FlutterConfig config) {
  if (config.mods['android']?['manifest'] == null) return config;
  final existing = config.mods['android']!['manifest']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = _manifestPath(props.modRequest.platformProjectRoot);
    XmlDocument doc;
    try {
      doc = await readXmlAsync(filePath);
    } catch (_) {
      doc = XmlDocument.parse(
          '<manifest xmlns:android="http://schemas.android.com/apk/res/android"/>');
    }

    final result = await existing(props.copyWith(modResults: doc));

    if (!props.modRequest.introspect) {
      await writeXmlAsync(filePath, result.modResults as XmlDocument);
    }
    return result;
  }

  return config.withRegisteredMod('android', 'manifest', provider);
}

// ---------------------------------------------------------------------------
// strings.xml  (XmlDocument)
// ---------------------------------------------------------------------------

FlutterConfig _withStringsBaseMod(FlutterConfig config) {
  if (config.mods['android']?['strings'] == null) return config;
  final existing = config.mods['android']!['strings']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = _stringsPath(props.modRequest.platformProjectRoot);
    XmlDocument doc;
    try {
      doc = await readXmlAsync(filePath);
    } catch (_) {
      doc = XmlDocument.parse(
          '<?xml version="1.0" encoding="utf-8"?><resources/>');
    }

    final result = await existing(props.copyWith(modResults: doc));

    if (!props.modRequest.introspect) {
      await writeXmlAsync(filePath, result.modResults as XmlDocument);
    }
    return result;
  }

  return config.withRegisteredMod('android', 'strings', provider);
}

// ---------------------------------------------------------------------------
// colors.xml  (XmlDocument)
// ---------------------------------------------------------------------------

FlutterConfig _withColorsBaseMod(FlutterConfig config) {
  if (config.mods['android']?['colors'] == null) return config;
  final existing = config.mods['android']!['colors']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = _colorsPath(props.modRequest.platformProjectRoot);
    XmlDocument doc;
    try {
      doc = await readXmlAsync(filePath);
    } catch (_) {
      doc = XmlDocument.parse(
          '<?xml version="1.0" encoding="utf-8"?><resources/>');
    }

    final result = await existing(props.copyWith(modResults: doc));

    if (!props.modRequest.introspect) {
      // Ensure parent directory exists.
      final file = File(filePath);
      file.parent.createSync(recursive: true);
      await writeXmlAsync(filePath, result.modResults as XmlDocument);
    }
    return result;
  }

  return config.withRegisteredMod('android', 'colors', provider);
}

// ---------------------------------------------------------------------------
// app/build.gradle  (raw String)
// ---------------------------------------------------------------------------

FlutterConfig _withAppBuildGradleBaseMod(FlutterConfig config) {
  if (config.mods['android']?['appBuildGradle'] == null) return config;
  final existing = config.mods['android']!['appBuildGradle']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = p.join(
        props.modRequest.platformProjectRoot, 'app', 'build.gradle');
    String contents = '';
    try {
      contents = await File(filePath).readAsString();
    } catch (_) {}

    final result = await existing(props.copyWith(modResults: contents));

    if (!props.modRequest.introspect) {
      await File(filePath).writeAsString(result.modResults as String);
    }
    return result;
  }

  return config.withRegisteredMod('android', 'appBuildGradle', provider);
}

// ---------------------------------------------------------------------------
// build.gradle (project root)  (raw String)
// ---------------------------------------------------------------------------

FlutterConfig _withProjectBuildGradleBaseMod(FlutterConfig config) {
  if (config.mods['android']?['projectBuildGradle'] == null) return config;
  final existing = config.mods['android']!['projectBuildGradle']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath =
        p.join(props.modRequest.platformProjectRoot, 'build.gradle');
    String contents = '';
    try {
      contents = await File(filePath).readAsString();
    } catch (_) {}

    final result = await existing(props.copyWith(modResults: contents));

    if (!props.modRequest.introspect) {
      await File(filePath).writeAsString(result.modResults as String);
    }
    return result;
  }

  return config.withRegisteredMod('android', 'projectBuildGradle', provider);
}

// ---------------------------------------------------------------------------
// settings.gradle  (raw String)
// ---------------------------------------------------------------------------

FlutterConfig _withSettingsGradleBaseMod(FlutterConfig config) {
  if (config.mods['android']?['settingsGradle'] == null) return config;
  final existing = config.mods['android']!['settingsGradle']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath =
        p.join(props.modRequest.platformProjectRoot, 'settings.gradle');
    String contents = '';
    try {
      contents = await File(filePath).readAsString();
    } catch (_) {}

    final result = await existing(props.copyWith(modResults: contents));

    if (!props.modRequest.introspect) {
      await File(filePath).writeAsString(result.modResults as String);
    }
    return result;
  }

  return config.withRegisteredMod('android', 'settingsGradle', provider);
}

// ---------------------------------------------------------------------------
// gradle.properties  (List<PropertiesItem>)
// ---------------------------------------------------------------------------

FlutterConfig _withGradlePropertiesBaseMod(FlutterConfig config) {
  if (config.mods['android']?['gradleProperties'] == null) return config;
  final existing = config.mods['android']!['gradleProperties']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = p.join(
        props.modRequest.platformProjectRoot, 'gradle.properties');
    List<PropertiesItem> items = [];
    try {
      items = parsePropertiesFile(await File(filePath).readAsString());
    } catch (_) {}

    final result = await existing(props.copyWith(modResults: items));

    if (!props.modRequest.introspect) {
      await File(filePath).writeAsString(
          propertiesListToString(result.modResults as List<PropertiesItem>));
    }
    return result;
  }

  return config.withRegisteredMod('android', 'gradleProperties', provider);
}

// ---------------------------------------------------------------------------
// dangerous  (no file)
// ---------------------------------------------------------------------------

FlutterConfig _withDangerousBaseMod(FlutterConfig config) {
  if (config.mods['android']?['dangerous'] == null) return config;
  final existing = config.mods['android']!['dangerous']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    return existing(props.copyWith(modResults: null));
  }

  return config.withRegisteredMod('android', 'dangerous', provider);
}

// ---------------------------------------------------------------------------
// Path helpers
// ---------------------------------------------------------------------------

String _manifestPath(String platformRoot) =>
    p.join(platformRoot, 'app', 'src', 'main', 'AndroidManifest.xml');

String _stringsPath(String platformRoot) =>
    p.join(platformRoot, 'app', 'src', 'main', 'res', 'values', 'strings.xml');

String _colorsPath(String platformRoot) =>
    p.join(platformRoot, 'app', 'src', 'main', 'res', 'values', 'colors.xml');
