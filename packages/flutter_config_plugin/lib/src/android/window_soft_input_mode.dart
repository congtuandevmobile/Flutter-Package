library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

/// windowSoftInputMode values.
enum WindowSoftInputMode {
  adjustResize('adjustResize'),
  adjustPan('adjustPan'),
  adjustNothing('adjustNothing'),
  adjustUnspecified('adjustUnspecified'),
  stateAlwaysVisible('stateAlwaysVisible'),
  stateAlwaysHidden('stateAlwaysHidden'),
  stateHidden('stateHidden'),
  stateVisible('stateVisible'),
  stateUnchanged('stateUnchanged'),
  stateUnspecified('stateUnspecified');

  const WindowSoftInputMode(this.value);
  final String value;
}

// ---------------------------------------------------------------------------
// withWindowSoftInputMode
// ---------------------------------------------------------------------------

/// Set `android:windowSoftInputMode` on the main `<activity>`.
ConfigPlugin withWindowSoftInputMode(WindowSoftInputMode mode) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          final activity = getMainActivityOrThrow(doc);
          setAttribute(
              activity, 'android:windowSoftInputMode', mode.value);
          return props.copyWith(modResults: doc);
        },
      );
}
