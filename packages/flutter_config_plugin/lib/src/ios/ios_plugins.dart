library;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withInfoPlist
// ---------------------------------------------------------------------------

/// Modify iOS Info.plist.
///
/// ```dart
/// config = withInfoPlist(config, (plist) {
///   plist['NSCameraUsageDescription'] = 'Needed for scanning';
///   return plist;
/// });
/// ```
FlutterConfig withInfoPlist(
  FlutterConfig config,
  Map<String, dynamic> Function(Map<String, dynamic> plist) action,
) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'infoPlist',
    action: (props) async {
      final plist = Map<String, dynamic>.from(
          (props.modResults as Map<String, dynamic>?) ?? {});
      final modified = action(plist);
      return props.copyWith(modResults: modified);
    },
  );
}

/// Async variant of [withInfoPlist].
FlutterConfig withInfoPlistAsync(
  FlutterConfig config,
  Future<Map<String, dynamic>> Function(Map<String, dynamic> plist) action,
) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'infoPlist',
    action: (props) async {
      final plist = Map<String, dynamic>.from(
          (props.modResults as Map<String, dynamic>?) ?? {});
      final modified = await action(plist);
      return props.copyWith(modResults: modified);
    },
  );
}

// ---------------------------------------------------------------------------
// withEntitlements
// ---------------------------------------------------------------------------

/// Modify the iOS .entitlements plist.
FlutterConfig withEntitlements(
  FlutterConfig config,
  Map<String, dynamic> Function(Map<String, dynamic> entitlements) action,
) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'entitlements',
    action: (props) async {
      final data = Map<String, dynamic>.from(
          (props.modResults as Map<String, dynamic>?) ?? {});
      return props.copyWith(modResults: action(data));
    },
  );
}

// ---------------------------------------------------------------------------
// withPodfile
// ---------------------------------------------------------------------------

/// Modify the iOS Podfile (raw text).
FlutterConfig withPodfile(
  FlutterConfig config,
  String Function(String contents) action,
) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'podfile',
    action: (props) async {
      final contents = (props.modResults as String?) ?? '';
      return props.copyWith(modResults: action(contents));
    },
  );
}

// ---------------------------------------------------------------------------
// Convenience helpers
// ---------------------------------------------------------------------------

/// Add a usage description to Info.plist (e.g. NSCameraUsageDescription).
ConfigPlugin withIosPermission({
  required String key,
  required String description,
}) {
  return (config) => withInfoPlist(config, (plist) {
        plist[key] = description;
        return plist;
      });
}

/// Set CFBundleDisplayName in Info.plist.
ConfigPlugin withDisplayName(String displayName) {
  return (config) => withInfoPlist(config, (plist) {
        plist['CFBundleDisplayName'] = displayName;
        return plist;
      });
}

/// Set CFBundleVersion in Info.plist.
ConfigPlugin withBuildNumber(String buildNumber) {
  return (config) => withInfoPlist(config, (plist) {
        plist['CFBundleVersion'] = buildNumber;
        return plist;
      });
}

/// Enable ATS arbitrary loads in Info.plist.
ConfigPlugin withArbitraryLoads(bool allow) {
  return (config) => withInfoPlist(config, (plist) {
        plist['NSAppTransportSecurity'] = {
          'NSAllowsArbitraryLoads': allow,
        };
        return plist;
      });
}
