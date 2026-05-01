library;

import '../types.dart';
import '../with_mod.dart';
import 'ios_config_types.dart';
import 'utils/xcodeproj.dart';

// ---------------------------------------------------------------------------
// withDeviceFamily
// ---------------------------------------------------------------------------

/// Set TARGETED_DEVICE_FAMILY in the Xcode build settings.
///
/// - [DeviceFamilyConfig.handset] → "1" (iPhone only)
/// - [DeviceFamilyConfig.tablet] → "2" (iPad only)
/// - [DeviceFamilyConfig.universal] → "1,2" (both)
ConfigPlugin withDeviceFamily(DeviceFamilyConfig family) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'xcodeproj',
        action: (props) async {
          final project = props.modResults as XcodeProject?;
          if (project == null) return props;
          project.setBuildProperty(
              'TARGETED_DEVICE_FAMILY', _familyValue(family));
          return props;
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _familyValue(DeviceFamilyConfig family) {
  switch (family) {
    case DeviceFamilyConfig.handset:
      return '1';
    case DeviceFamilyConfig.tablet:
      return '2';
    case DeviceFamilyConfig.universal:
      return '1,2';
  }
}

DeviceFamilyConfig getDeviceFamily(FlutterConfig config) =>
    DeviceFamilyConfig.universal;

List<int> getDeviceFamilies(FlutterConfig config) {
  final family = getDeviceFamily(config);
  switch (family) {
    case DeviceFamilyConfig.handset:
      return [1];
    case DeviceFamilyConfig.tablet:
      return [2];
    case DeviceFamilyConfig.universal:
      return [1, 2];
  }
}
