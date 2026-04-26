library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

// ---------------------------------------------------------------------------
// withAndroidPermission (single)
// ---------------------------------------------------------------------------

/// Add a single `<uses-permission>` to AndroidManifest.xml.
ConfigPlugin withAndroidPermission(String permissionName) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          addPermission(doc, permissionName);
          return props.copyWith(modResults: doc);
        },
      );
}

// ---------------------------------------------------------------------------
// withAndroidPermissions (multiple)
// ---------------------------------------------------------------------------

/// Add multiple permissions at once.
ConfigPlugin withAndroidPermissions(List<String> permissionNames) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          for (final name in permissionNames) {
            addPermission(doc, name);
          }
          return props.copyWith(modResults: doc);
        },
      );
}

/// Well-known Android permission names.
class AndroidPermissions {
  static const camera = 'android.permission.CAMERA';
  static const internet = 'android.permission.INTERNET';
  static const readExternalStorage = 'android.permission.READ_EXTERNAL_STORAGE';
  static const writeExternalStorage = 'android.permission.WRITE_EXTERNAL_STORAGE';
  static const accessFineLocation = 'android.permission.ACCESS_FINE_LOCATION';
  static const accessCoarseLocation = 'android.permission.ACCESS_COARSE_LOCATION';
  static const recordAudio = 'android.permission.RECORD_AUDIO';
  static const vibrate = 'android.permission.VIBRATE';
  static const receiveBoot = 'android.permission.RECEIVE_BOOT_COMPLETED';
  static const wakeLock = 'android.permission.WAKE_LOCK';
  static const bluetooth = 'android.permission.BLUETOOTH';
  static const bluetoothAdmin = 'android.permission.BLUETOOTH_ADMIN';
  static const bluetoothConnect = 'android.permission.BLUETOOTH_CONNECT';
  static const bluetoothScan = 'android.permission.BLUETOOTH_SCAN';
  static const nfc = 'android.permission.NFC';
  static const contacts = 'android.permission.READ_CONTACTS';
  static const readMedia = 'android.permission.READ_MEDIA_IMAGES';
}
