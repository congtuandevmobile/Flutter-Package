library;

import '../types.dart';
import '../with_mod.dart';

/// Enable or disable NSAppTransportSecurity.NSAllowsArbitraryLoads in Info.plist.
ConfigPlugin withArbitraryLoads(bool allow) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist['NSAppTransportSecurity'] = {'NSAllowsArbitraryLoads': allow};
          return props.copyWith(modResults: plist);
        },
      );
}

Map<String, dynamic>? getAppTransportSecurity(Map<String, dynamic> plist) =>
    plist['NSAppTransportSecurity'] as Map<String, dynamic>?;

bool getArbitraryLoads(Map<String, dynamic> plist) =>
    (getAppTransportSecurity(plist)?['NSAllowsArbitraryLoads'] as bool?) ??
    false;
