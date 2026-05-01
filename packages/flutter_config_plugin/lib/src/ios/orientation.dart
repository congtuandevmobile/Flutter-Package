library;

import '../types.dart';
import '../with_mod.dart';
import 'ios_config_types.dart';

// ---------------------------------------------------------------------------
// withOrientation
// ---------------------------------------------------------------------------

/// Set UISupportedInterfaceOrientations in Info.plist.
///
/// [orientation]: 'portrait', 'landscape', or 'all' (default).
ConfigPlugin withOrientation(OrientationConfig orientation) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          setOrientation(plist, orientation);
          return props.copyWith(modResults: plist);
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void setOrientation(Map<String, dynamic> plist, OrientationConfig orientation) {
  final values = _orientationValues(orientation);
  plist['UISupportedInterfaceOrientations'] = values;
  // Also set for iPad.
  plist['UISupportedInterfaceOrientations~ipad'] = allOrientations.map((o) => o.value).toList();
}

List<String> _orientationValues(OrientationConfig orientation) {
  switch (orientation) {
    case OrientationConfig.portrait:
      return portraitOrientations.map((o) => o.value).toList();
    case OrientationConfig.landscape:
      return landscapeOrientations.map((o) => o.value).toList();
    case OrientationConfig.all:
      return allOrientations.map((o) => o.value).toList();
  }
}

OrientationConfig? getOrientation(Map<String, dynamic> plist) {
  final values = plist['UISupportedInterfaceOrientations'];
  if (values == null) return null;
  final list = List<String>.from(values as List);
  final hasPortrait = list.contains('UIInterfaceOrientationPortrait');
  final hasLandscape = list.contains('UIInterfaceOrientationLandscapeLeft') ||
      list.contains('UIInterfaceOrientationLandscapeRight');
  if (hasPortrait && hasLandscape) return OrientationConfig.all;
  if (hasPortrait) return OrientationConfig.portrait;
  if (hasLandscape) return OrientationConfig.landscape;
  return null;
}
