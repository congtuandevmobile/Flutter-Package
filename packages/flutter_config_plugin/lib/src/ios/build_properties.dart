library;

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withIosBuildProperties
// ---------------------------------------------------------------------------

/// Modify ios/Podfile.properties.json with arbitrary key-value pairs.
///
/// This is the iOS equivalent of expo's BuildProperties module.
ConfigPlugin withIosBuildProperties(Map<String, String> properties) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'dangerous',
        action: (props) async {
          if (props.modRequest.introspect) return props;
          final filePath = p.join(
              props.modRequest.platformProjectRoot, 'Podfile.properties.json');
          Map<String, dynamic> existing = {};
          final file = File(filePath);
          if (file.existsSync()) {
            try {
              existing =
                  Map<String, dynamic>.from(jsonDecode(file.readAsStringSync()));
            } catch (_) {}
          }
          for (final e in properties.entries) {
            existing[e.key] = e.value;
          }
          await file.writeAsString(
              const JsonEncoder.withIndent('  ').convert(existing) + '\n');
          return props;
        },
      );
}

/// Pre-built plugin: configure Hermes JS engine.
ConfigPlugin withHermes({required bool enabled}) =>
    withIosBuildProperties({'expo.jsEngine': enabled ? 'hermes' : 'jsc'});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<Map<String, dynamic>> readPodfileProperties(String iosRoot) async {
  final file = File(p.join(iosRoot, 'Podfile.properties.json'));
  if (!file.existsSync()) return {};
  try {
    return Map<String, dynamic>.from(jsonDecode(await file.readAsString()));
  } catch (_) {
    return {};
  }
}
