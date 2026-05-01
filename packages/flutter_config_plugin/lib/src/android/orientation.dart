library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

/// Android screen orientation values.
enum AndroidOrientation {
  portrait('portrait'),
  landscape('landscape'),
  sensorPortrait('sensorPortrait'),
  sensorLandscape('sensorLandscape'),
  sensor('sensor'),
  fullSensor('fullSensor'),
  nosensor('nosensor'),
  unspecified('unspecified');

  const AndroidOrientation(this.value);

  /// The string value used in `android:screenOrientation`.
  final String value;
}

// ---------------------------------------------------------------------------
// withAndroidOrientation
// ---------------------------------------------------------------------------

/// Set `android:screenOrientation` on the main `<activity>`.
ConfigPlugin withAndroidOrientation(AndroidOrientation orientation) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          final activity = getMainActivityOrThrow(doc);
          setAttribute(
              activity, 'android:screenOrientation', orientation.value);
          return props.copyWith(modResults: doc);
        },
      );
}

String? getAndroidOrientation(dynamic doc) {
  if (doc == null) return null;
  final activity = getMainActivity(doc);
  return activity?.getAttribute('android:screenOrientation');
}
