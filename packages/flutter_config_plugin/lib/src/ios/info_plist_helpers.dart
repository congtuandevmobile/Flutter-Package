library;

import '../types.dart';
import '../with_mod.dart';

/// Set an arbitrary key-value pair in Info.plist.
ConfigPlugin withInfoPlistValue(String key, dynamic value) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from((props.modResults as Map<String, dynamic>?) ?? {});
          plist[key] = value;
          return props.copyWith(modResults: plist);
        },
      );
}
