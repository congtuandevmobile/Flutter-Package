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

/// Constants for well-known Android permission names.
///
/// Use with [withAndroidPermission] or [withAndroidPermissions].
class AndroidPermissions {
  AndroidPermissions._();

  /// `android.permission.CAMERA`
  static const camera = 'android.permission.CAMERA';

  /// `android.permission.INTERNET`
  static const internet = 'android.permission.INTERNET';

  /// `android.permission.READ_EXTERNAL_STORAGE`
  static const readExternalStorage = 'android.permission.READ_EXTERNAL_STORAGE';

  /// `android.permission.WRITE_EXTERNAL_STORAGE`
  static const writeExternalStorage = 'android.permission.WRITE_EXTERNAL_STORAGE';

  /// `android.permission.ACCESS_FINE_LOCATION`
  static const accessFineLocation = 'android.permission.ACCESS_FINE_LOCATION';

  /// `android.permission.ACCESS_COARSE_LOCATION`
  static const accessCoarseLocation = 'android.permission.ACCESS_COARSE_LOCATION';

  /// `android.permission.RECORD_AUDIO`
  static const recordAudio = 'android.permission.RECORD_AUDIO';

  /// `android.permission.VIBRATE`
  static const vibrate = 'android.permission.VIBRATE';

  /// `android.permission.RECEIVE_BOOT_COMPLETED`
  static const receiveBoot = 'android.permission.RECEIVE_BOOT_COMPLETED';

  /// `android.permission.WAKE_LOCK`
  static const wakeLock = 'android.permission.WAKE_LOCK';

  /// `android.permission.BLUETOOTH`
  static const bluetooth = 'android.permission.BLUETOOTH';

  /// `android.permission.BLUETOOTH_ADMIN`
  static const bluetoothAdmin = 'android.permission.BLUETOOTH_ADMIN';

  /// `android.permission.BLUETOOTH_CONNECT`
  static const bluetoothConnect = 'android.permission.BLUETOOTH_CONNECT';

  /// `android.permission.BLUETOOTH_SCAN`
  static const bluetoothScan = 'android.permission.BLUETOOTH_SCAN';

  /// `android.permission.NFC`
  static const nfc = 'android.permission.NFC';

  /// `android.permission.READ_CONTACTS`
  static const contacts = 'android.permission.READ_CONTACTS';

  /// `android.permission.READ_MEDIA_IMAGES`
  static const readMedia = 'android.permission.READ_MEDIA_IMAGES';
}
