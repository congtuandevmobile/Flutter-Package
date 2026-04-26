library;

import '../types.dart';
import '../with_mod.dart';

/// Set ITSAppUsesNonExemptEncryption in Info.plist.
///
/// Required for App Store submission if your app uses encryption.
ConfigPlugin withUsesNonExemptEncryption(bool value) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist['ITSAppUsesNonExemptEncryption'] = value;
          return props.copyWith(modResults: plist);
        },
      );
}

bool? getUsesNonExemptEncryption(Map<String, dynamic> plist) =>
    plist['ITSAppUsesNonExemptEncryption'] as bool?;
