library;

import 'dart:io';
import 'package:path/path.dart' as p;

import '../types.dart';
import '../utils/plist_utils.dart';
import 'utils/xcodeproj.dart';

/// Register iOS file-provider base mods onto [config].
/// Providers are only registered when a user mod has already been registered
/// for that modName, ensuring we don't create spurious read/write cycles.
FlutterConfig withIosBaseMods(FlutterConfig config, String projectRoot) {
  config = _withInfoPlistBaseMod(config);
  config = _withEntitlementsBaseMod(config);
  config = _withPodfileBaseMod(config);
  config = _withXcodeprojBaseMod(config);
  config = _withDangerousBaseMod(config);
  return config;
}

// ---------------------------------------------------------------------------
// Info.plist  (Map<String, dynamic>)
// ---------------------------------------------------------------------------

FlutterConfig _withInfoPlistBaseMod(FlutterConfig config) {
  if (config.mods['ios']?['infoPlist'] == null) return config;
  final existing = config.mods['ios']!['infoPlist']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = _infoPlistPath(props.modRequest.platformProjectRoot);
    Map<String, dynamic> plist;
    try {
      plist = parsePlist(await File(filePath).readAsString());
    } catch (_) {
      plist = {};
    }

    final result = await existing(props.copyWith(modResults: plist));

    if (!props.modRequest.introspect) {
      await File(filePath).writeAsString(
          buildPlist(result.modResults as Map<String, dynamic>));
    }
    return result;
  }

  return config.withRegisteredMod('ios', 'infoPlist', provider);
}

// ---------------------------------------------------------------------------
// Entitlements  (Map<String, dynamic>)
// ---------------------------------------------------------------------------

FlutterConfig _withEntitlementsBaseMod(FlutterConfig config) {
  if (config.mods['ios']?['entitlements'] == null) return config;
  final existing = config.mods['ios']!['entitlements']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = _entitlementsPath(props.modRequest.platformProjectRoot);
    Map<String, dynamic> plist;
    try {
      plist = parsePlist(await File(filePath).readAsString());
    } catch (_) {
      plist = {};
    }

    final result = await existing(props.copyWith(modResults: plist));

    if (!props.modRequest.introspect) {
      await File(filePath).writeAsString(
          buildPlist(result.modResults as Map<String, dynamic>));
    }
    return result;
  }

  return config.withRegisteredMod('ios', 'entitlements', provider);
}

// ---------------------------------------------------------------------------
// Podfile  (raw String)
// ---------------------------------------------------------------------------

FlutterConfig _withPodfileBaseMod(FlutterConfig config) {
  if (config.mods['ios']?['podfile'] == null) return config;
  final existing = config.mods['ios']!['podfile']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final filePath = p.join(props.modRequest.platformProjectRoot, 'Podfile');
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

  return config.withRegisteredMod('ios', 'podfile', provider);
}

// ---------------------------------------------------------------------------
// Xcodeproj  (XcodeProject)
// ---------------------------------------------------------------------------

FlutterConfig _withXcodeprojBaseMod(FlutterConfig config) {
  if (config.mods['ios']?['xcodeproj'] == null) return config;
  final existing = config.mods['ios']!['xcodeproj']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    final iosRoot = props.modRequest.platformProjectRoot;
    XcodeProject project;
    try {
      final pbxprojPath = getPbxprojPath(iosRoot);
      project = await XcodeProject.load(pbxprojPath);
    } catch (_) {
      // Create an empty project placeholder if .pbxproj not found.
      project = XcodeProject.fromContents('', '');
    }

    final result = await existing(props.copyWith(modResults: project));
    final modified = result.modResults as XcodeProject?;

    if (!props.modRequest.introspect && modified != null && modified.filepath.isNotEmpty) {
      await modified.save();
    }
    return result;
  }

  return config.withRegisteredMod('ios', 'xcodeproj', provider);
}

// ---------------------------------------------------------------------------
// dangerous  (no file — passes null modResults through the chain)
// ---------------------------------------------------------------------------

FlutterConfig _withDangerousBaseMod(FlutterConfig config) {
  if (config.mods['ios']?['dangerous'] == null) return config;
  final existing = config.mods['ios']!['dangerous']!;

  Future<ExportedConfig> provider(ExportedConfig props) async {
    return existing(props.copyWith(modResults: null));
  }

  return config.withRegisteredMod('ios', 'dangerous', provider);
}

// ---------------------------------------------------------------------------
// Path helpers
// ---------------------------------------------------------------------------

String _infoPlistPath(String platformRoot) =>
    p.join(platformRoot, 'Runner', 'Info.plist');

String _entitlementsPath(String platformRoot) =>
    p.join(platformRoot, 'Runner', 'Runner.entitlements');
