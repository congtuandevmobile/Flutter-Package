library;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withIosPermission (single)
// ---------------------------------------------------------------------------

/// Add a single iOS usage description to Info.plist.
///
/// ```dart
/// withIosPermission(key: 'NSCameraUsageDescription', description: 'QR scanner')
/// ```
ConfigPlugin withIosPermission({
  required String key,
  required String description,
}) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist[key] = description;
          return props.copyWith(modResults: plist);
        },
      );
}

// ---------------------------------------------------------------------------
// withIosPermissions (multiple)
// ---------------------------------------------------------------------------

/// Add multiple iOS permission descriptions at once.
///
/// Pass `null` as a value to remove a key.
ConfigPlugin withIosPermissions(Map<String, String?> permissions) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          for (final entry in permissions.entries) {
            if (entry.value == null) {
              plist.remove(entry.key);
            } else {
              plist[entry.key] = entry.value;
            }
          }
          return props.copyWith(modResults: plist);
        },
      );
}

// ---------------------------------------------------------------------------
// Convenience helpers
// ---------------------------------------------------------------------------

/// Apply a permission map to [plist], supporting null to delete a key.
Map<String, dynamic> applyPermissions(
  Map<String, dynamic> plist,
  Map<String, String?> permissions,
) {
  for (final entry in permissions.entries) {
    if (entry.value == null) {
      plist.remove(entry.key);
    } else {
      plist.putIfAbsent(entry.key, () => entry.value!);
    }
  }
  return plist;
}

/// Well-known iOS permission keys.
class IosPermissions {
  static const camera = 'NSCameraUsageDescription';
  static const microphone = 'NSMicrophoneUsageDescription';
  static const photoLibrary = 'NSPhotoLibraryUsageDescription';
  static const photoLibraryAddUsage = 'NSPhotoLibraryAddUsageDescription';
  static const contacts = 'NSContactsUsageDescription';
  static const location = 'NSLocationWhenInUseUsageDescription';
  static const locationAlways = 'NSLocationAlwaysAndWhenInUseUsageDescription';
  static const motion = 'NSMotionUsageDescription';
  static const bluetooth = 'NSBluetoothAlwaysUsageDescription';
  static const bluetoothPeripheral = 'NSBluetoothPeripheralUsageDescription';
  static const speechRecognition = 'NSSpeechRecognitionUsageDescription';
  static const faceId = 'NSFaceIDUsageDescription';
  static const calendarFullAccess = 'NSCalendarsFullAccessUsageDescription';
  static const calendarWriteOnly = 'NSCalendarsWriteOnlyAccessUsageDescription';
  static const reminders = 'NSRemindersFullAccessUsageDescription';
  static const healthShare = 'NSHealthShareUsageDescription';
  static const healthUpdate = 'NSHealthUpdateUsageDescription';
  static const trackingUsage = 'NSUserTrackingUsageDescription';
}
