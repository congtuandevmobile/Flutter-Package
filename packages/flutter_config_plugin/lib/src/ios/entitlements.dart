library;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withEntitlements
// ---------------------------------------------------------------------------

/// Modify the iOS .entitlements plist.
///
/// ```dart
/// config = withEntitlements(config, (entitlements) {
///   entitlements['aps-environment'] = 'development';
///   return entitlements;
/// });
/// ```
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
// withAssociatedDomains
// ---------------------------------------------------------------------------

/// Add associated domains to the entitlements file.
/// Equivalent to expo's `withAssociatedDomains`.
ConfigPlugin withAssociatedDomains(List<String> domains) {
  return (config) => withEntitlements(config, (e) {
        final key = 'com.apple.developer.associated-domains';
        final existing = List<String>.from(e[key] as List? ?? []);
        for (final d in domains) {
          if (!existing.contains(d)) existing.add(d);
        }
        e[key] = existing;
        return e;
      });
}

/// Add push notification entitlements.
ConfigPlugin withPushNotifications({bool development = true}) {
  return (config) => withEntitlements(config, (e) {
        e['aps-environment'] = development ? 'development' : 'production';
        return e;
      });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> setAssociatedDomains(
    Map<String, dynamic> entitlements, List<String> domains) {
  entitlements['com.apple.developer.associated-domains'] = domains;
  return entitlements;
}

List<String> getAssociatedDomains(Map<String, dynamic> entitlements) {
  return List<String>.from(
      entitlements['com.apple.developer.associated-domains'] as List? ?? []);
}
