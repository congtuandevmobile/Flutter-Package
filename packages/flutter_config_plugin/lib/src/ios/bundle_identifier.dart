library;

import '../types.dart';
import '../with_mod.dart';
import 'utils/xcodeproj.dart';

// ---------------------------------------------------------------------------
// withBundleIdentifier
// ---------------------------------------------------------------------------

/// Set the iOS bundle identifier in both Info.plist and the Xcode project.
///
/// Equivalent to expo's `withBundleIdentifier`.
ConfigPlugin withBundleIdentifier(String bundleId) {
  return (config) {
    config = config.copyWith(bundleIdentifier: bundleId);
    config = _withInfoPlistBundleId(config, bundleId);
    config = _withXcodeProjectBundleId(config, bundleId);
    return config;
  };
}

FlutterConfig _withInfoPlistBundleId(FlutterConfig config, String bundleId) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'infoPlist',
    action: (props) async {
      final plist = Map<String, dynamic>.from(
          (props.modResults as Map<String, dynamic>?) ?? {});
      plist['CFBundleIdentifier'] = bundleId;
      return props.copyWith(modResults: plist);
    },
  );
}

FlutterConfig _withXcodeProjectBundleId(FlutterConfig config, String bundleId) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'xcodeproj',
    action: (props) async {
      final project = props.modResults as XcodeProject?;
      if (project == null) return props;
      project.setBuildProperty('PRODUCT_BUNDLE_IDENTIFIER', bundleId);
      return props;
    },
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String? getBundleIdentifier(FlutterConfig config) => config.bundleIdentifier;

/// Reset Info.plist CFBundleIdentifier to the xcodeproj variable reference
/// (Apple-recommended approach).
Map<String, dynamic> resetPlistBundleIdentifier(Map<String, dynamic> plist) {
  plist['CFBundleIdentifier'] = r'$(PRODUCT_BUNDLE_IDENTIFIER)';
  return plist;
}
