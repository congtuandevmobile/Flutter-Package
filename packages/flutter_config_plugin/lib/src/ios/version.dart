library;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withVersion / withBuildNumber
// ---------------------------------------------------------------------------

/// Set CFBundleShortVersionString (marketing version, e.g. "1.2.3").
ConfigPlugin withVersion([String? version]) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist['CFBundleShortVersionString'] =
              version ?? props.config.version;
          return props.copyWith(modResults: plist);
        },
      );
}

/// Set CFBundleVersion (build number, e.g. "42").
ConfigPlugin withBuildNumber(String buildNumber) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist['CFBundleVersion'] = buildNumber;
          return props.copyWith(modResults: plist);
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String getVersion(FlutterConfig config) => config.version;

Map<String, dynamic> setBuildNumber(
    Map<String, dynamic> plist, String buildNumber) {
  plist['CFBundleVersion'] = buildNumber;
  return plist;
}
