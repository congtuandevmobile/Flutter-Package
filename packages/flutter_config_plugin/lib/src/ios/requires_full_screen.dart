library;

import '../types.dart';
import '../with_mod.dart';

/// Set UIRequiresFullScreen in Info.plist (disables iPad multitasking).
ConfigPlugin withRequiresFullScreen(bool requiresFullScreen) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          setRequiresFullScreen(plist, requiresFullScreen);
          return props.copyWith(modResults: plist);
        },
      );
}

void setRequiresFullScreen(Map<String, dynamic> plist, bool value) {
  plist['UIRequiresFullScreen'] = value;
  if (value) {
    // Apple requires all 4 orientations be listed when UIRequiresFullScreen is set.
    plist['UISupportedInterfaceOrientations~ipad'] = [
      'UIInterfaceOrientationPortrait',
      'UIInterfaceOrientationPortraitUpsideDown',
      'UIInterfaceOrientationLandscapeLeft',
      'UIInterfaceOrientationLandscapeRight',
    ];
  }
}

bool getRequiresFullScreen(Map<String, dynamic> plist) =>
    (plist['UIRequiresFullScreen'] as bool?) ?? false;
