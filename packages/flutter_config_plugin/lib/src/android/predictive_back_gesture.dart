library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

// ---------------------------------------------------------------------------
// withPredictiveBackGesture
// ---------------------------------------------------------------------------

/// Enable or disable Android 13+ predictive back gesture.
///
/// Sets `android:enableOnBackInvokedCallback` on the `<application>` element.
ConfigPlugin withPredictiveBackGesture({required bool enabled}) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          final app = getMainApplicationOrThrow(doc);
          setAttribute(app, 'android:enableOnBackInvokedCallback',
              enabled.toString());
          return props.copyWith(modResults: doc);
        },
      );
}
