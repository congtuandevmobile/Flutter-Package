library;

import '../types.dart';
import '../with_mod.dart';
import 'ios_config_types.dart';

// ---------------------------------------------------------------------------
// withScheme
// ---------------------------------------------------------------------------

/// Add URL scheme(s) to CFBundleURLTypes in Info.plist.
ConfigPlugin withScheme(List<String> schemes) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          setSchemes(plist, schemes);
          return props.copyWith(modResults: plist);
        },
      );
}

/// Add URL scheme(s) with custom role and name to CFBundleURLTypes in Info.plist.
ConfigPlugin withIosUrlScheme({
  required List<String> schemes,
  String? role,
  String? name,
}) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          final existing = List<Map<String, dynamic>>.from(
            (plist['CFBundleURLTypes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          );
          
          final Map<String, dynamic> newType = {
            'CFBundleURLSchemes': schemes,
          };
          if (role != null) newType['CFBundleTypeRole'] = role;
          if (name != null) newType['CFBundleURLName'] = name;
          
          existing.add(newType);
          plist['CFBundleURLTypes'] = existing;

          return props.copyWith(modResults: plist);
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void setSchemes(Map<String, dynamic> plist, List<String> schemes) {
  final existing = List<Map<String, dynamic>>.from(
    (plist['CFBundleURLTypes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
  );

  for (final scheme in schemes) {
    if (!hasScheme(existing, scheme)) {
      existing.add(UrlScheme(cfBundleURLSchemes: [scheme]).toMap());
    }
  }

  plist['CFBundleURLTypes'] = existing;
}

bool hasScheme(List<Map<String, dynamic>> urlTypes, String scheme) {
  for (final type in urlTypes) {
    final schemesList = (type['CFBundleURLSchemes'] as List?)?.cast<String>() ?? [];
    if (schemesList.contains(scheme)) return true;
  }
  return false;
}

void appendScheme(Map<String, dynamic> plist, String scheme) =>
    setSchemes(plist, [scheme]);

void removeScheme(Map<String, dynamic> plist, String scheme) {
  final existing = List<Map<String, dynamic>>.from(
    (plist['CFBundleURLTypes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
  );
  existing.removeWhere((type) {
    final schemes = (type['CFBundleURLSchemes'] as List?)?.cast<String>() ?? [];
    return schemes.contains(scheme);
  });
  plist['CFBundleURLTypes'] = existing;
}

List<String> getSchemesFromPlist(Map<String, dynamic> plist) {
  final urlTypes = List<Map<String, dynamic>>.from(
    (plist['CFBundleURLTypes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
  );
  return urlTypes
      .expand((type) =>
          (type['CFBundleURLSchemes'] as List?)?.cast<String>() ?? <String>[])
      .toList();
}
