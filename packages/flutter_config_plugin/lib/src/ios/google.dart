library;

import 'dart:io';
import 'package:path/path.dart' as p;

import '../types.dart';
import '../with_mod.dart';
import '../utils/plist_utils.dart';

// ---------------------------------------------------------------------------
// withGoogleServicesFile
// ---------------------------------------------------------------------------

/// Copy GoogleService-Info.plist into the ios project and configure Google
/// Sign-In (REVERSED_CLIENT_ID in Info.plist).
///
/// [sourcePath]: path relative to the project root (e.g. "GoogleService-Info.plist").
ConfigPlugin withIosGoogleServicesFile(String sourcePath) {
  return (config) {
    // 1. Copy file via dangerous mod.
    config = withMod(
      config,
      platform: 'ios',
      modName: 'dangerous',
      action: (props) async {
        if (props.modRequest.introspect) return props;
        final src = File(p.join(props.modRequest.projectRoot, sourcePath));
        final dst = File(p.join(
            props.modRequest.platformProjectRoot, 'Runner', 'GoogleService-Info.plist'));
        if (src.existsSync()) {
          dst.parent.createSync(recursive: true);
          await src.copy(dst.path);
        }
        return props;
      },
    );

    // 2. Extract REVERSED_CLIENT_ID and add to Info.plist CFBundleURLTypes.
    config = withMod(
      config,
      platform: 'ios',
      modName: 'infoPlist',
      action: (props) async {
        final plist = Map<String, dynamic>.from(
            (props.modResults as Map<String, dynamic>?) ?? {});

        final googlePlistPath = p.join(
            props.modRequest.platformProjectRoot, 'Runner', 'GoogleService-Info.plist');
        final reversedClientId =
            await _getReversedClientId(googlePlistPath);
        if (reversedClientId != null) {
          final urlTypes = List<Map<String, dynamic>>.from(
              (plist['CFBundleURLTypes'] as List?)?.cast<Map<String, dynamic>>() ?? []);
          final alreadyHas = urlTypes.any((t) =>
              (t['CFBundleURLSchemes'] as List?)?.contains(reversedClientId) == true);
          if (!alreadyHas) {
            urlTypes.add({
              'CFBundleURLSchemes': [reversedClientId],
            });
            plist['CFBundleURLTypes'] = urlTypes;
          }
        }
        return props.copyWith(modResults: plist);
      },
    );

    return config;
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<String?> _getReversedClientId(String plistPath) async {
  final file = File(plistPath);
  if (!file.existsSync()) return null;
  try {
    final plist = parsePlist(await file.readAsString());
    return plist['REVERSED_CLIENT_ID'] as String?;
  } catch (_) {
    return null;
  }
}
