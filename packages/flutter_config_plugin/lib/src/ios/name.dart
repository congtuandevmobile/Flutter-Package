library;

import '../types.dart';
import '../with_mod.dart';
import 'utils/xcodeproj.dart';

// ---------------------------------------------------------------------------
// withDisplayName / withName / withProductName
// ---------------------------------------------------------------------------

/// Set CFBundleDisplayName in Info.plist (the name shown on the home screen).
ConfigPlugin withDisplayName(String displayName) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist['CFBundleDisplayName'] = displayName;
          return props.copyWith(modResults: plist);
        },
      );
}

/// Set CFBundleName in Info.plist (≤ 16 chars, used in lists).
ConfigPlugin withName(String name) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist['CFBundleName'] = name;
          return props.copyWith(modResults: plist);
        },
      );
}

/// Set PRODUCT_NAME in the Xcode build settings.
ConfigPlugin withProductName(String name) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'xcodeproj',
        action: (props) async {
          final project = props.modResults as XcodeProject?;
          if (project == null) return props;
          project.updateProductName(name);
          return props;
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> setDisplayName(FlutterConfig config, Map<String, dynamic> plist) {
  plist['CFBundleDisplayName'] = config.name;
  return plist;
}

Map<String, dynamic> setName(FlutterConfig config, Map<String, dynamic> plist) {
  final truncated =
      config.name.length > 16 ? config.name.substring(0, 16) : config.name;
  plist['CFBundleName'] = truncated;
  return plist;
}
