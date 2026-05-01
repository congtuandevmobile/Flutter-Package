import 'dart:io';
import 'package:flutter_config_plugin/flutter_config_plugin.dart';
import 'package:flutter_config_plugin/src/android/android_plugins.dart'
    hide withAndroidPermission;

void main() async {
  final projectDir = Directory('../../apps/flutter_package');
  if (!projectDir.existsSync()) {
    print('❌ Don\'t find directory: \${projectDir.path}');
    return;
  }

  // --- environment ---
  final env = 'dev'; // 'dev' | 'prod'
  final isProd = env == 'prod';

  final appName = isProd ? 'Tuan Test Prod' : 'Tuan Test UAT';
  final bundleId = isProd
      ? 'tuannc2.test.flutter-plugin'
      : 'tuannc2.test.flutter-plugin.dev';

  final apiUrl = isProd ? 'tuannc2.com.vn' : 'tuannc2-uat.com.vn';
  final googleMapsKey = 'abc-lll123';
  final bgGeoLicense = 'abc-ll123';

  // ID
  final fbAppId = '1234';
  final fbClientToken = 'abcd1234';
  final gidClientId = '123444.apps.googleusercontent.com';
  final googleScheme = 'com.googleusercontent.apps.1234';

  // --- INIT CONFIG ---
  var config = FlutterConfig(
    name: appName,
    bundleIdentifier: bundleId,
    applicationId: bundleId,
  );

  config = withPlugins(config, [
    // ==========================================
    // iOS PLUGINS
    // ==========================================
    withDisplayName(appName),
    withBundleIdentifier(bundleId),
    withDeploymentTarget('14.0'),

    // Quyền (Permissions)
    withIosPermissions({
      IosPermissions.camera:
          '"APPNAME" needs access to your camera to let you take a profile avatar photo.',
      IosPermissions.healthShare:
          '"APPNAME" needs read access to your health data to sync your activities.',
      IosPermissions.healthUpdate:
          '"APPNAME" needs write access to your health data.',
      IosPermissions.locationAlways:
          '"APPNAME" needs background location access to track your running activities.',
      IosPermissions.motion:
          'APPNAME uses motion data to improve activity tracking accuracy.',
      IosPermissions.location:
          '"APPNAME" needs access to your location to track your running activities.',
      IosPermissions.microphone: '"APPNAME" needs access to your microphone.',
      IosPermissions.photoLibraryAddUsage:
          '"APPNAME" needs access to save photos to your library.',
      IosPermissions.photoLibrary:
          'APPNAME needs access to your photo library to let you set a profile avatar.',
    }),

    // --- CẤU HÌNH INFO.PLIST (iOS) ---
    withInfoPlistValue('API_URL', apiUrl),
    withInfoPlistValue('GOOGLE_MAPS_API_KEY', googleMapsKey),
    withInfoPlistValue('GIDClientID', gidClientId),
    withInfoPlistValue('BGTaskSchedulerPermittedIdentifiers', [
      'com.tuannc2.healthkit.sync',
    ]),

    // Google Sign-In Scheme
    withIosUrlScheme(role: 'Editor', schemes: [googleScheme]),

    // Web Auth Callback Scheme
    withIosUrlScheme(
      role: 'Editor',
      name: 'tuannc2_callback',
      schemes: ['tuannc2', 'vn.com.tuannc2'],
    ),

    // ==========================================
    // ANDROID PLUGINS
    // ==========================================
    withAndroidName(appName),
    withAndroidPackage(bundleId),
    withPredictiveBackGesture(enabled: true),

    (config) {
      final permissions = [
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.CAMERA',
        'android.permission.READ_MEDIA_IMAGES',
        'android.permission.READ_MEDIA_VIDEO',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.ACCESS_BACKGROUND_LOCATION',
        'android.permission.FOREGROUND_SERVICE',
        'android.permission.FOREGROUND_SERVICE_LOCATION',
        'android.permission.FOREGROUND_SERVICE_DATA_SYNC',
        'android.permission.RECEIVE_BOOT_COMPLETED',
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        'android.permission.ACTIVITY_RECOGNITION',
        'com.google.android.gms.permission.ACTIVITY_RECOGNITION',
      ];
      var c = config;
      for (final p in permissions) {
        c = withAndroidPermission(p)(c);
      }
      return c;
    },

    withAndroidPermissionMaxSdk('android.permission.READ_EXTERNAL_STORAGE', 32),
    withAndroidPermissionMaxSdk(
      'android.permission.WRITE_EXTERNAL_STORAGE',
      32,
    ),
    withAndroidQueryIntent('android.intent.action.PROCESS_TEXT', 'text/plain'),

    withAndroidApplicationMetaData('flutterEmbedding', '2'),
    withAndroidApplicationMetaData(
      'com.google.android.geo.API_KEY',
      googleMapsKey,
    ),
    withAndroidApplicationMetaData(
      'com.google.android.gms.maps.RENDERER',
      'LATEST',
    ),

    // --- KHAI BÁO FILE PROVIDER ---
    withAndroidFileProvider(authorities: '$bundleId.fileprovider'),

    // ==========================================
    // THIRD-PARTY PLUGINS
    // ==========================================
  ]);

  print('Starting apply config ${appName}...');

  try {
    await compileModsAsync(
      config,
      CompileModsOptions(projectRoot: projectDir.path),
    );
    print('✅ Complete! Info.plist and AndroidManifest.xml have been updated.');
  } catch (e, stack) {
    print('❌ Error running config: \$e\\n\$stack');
  }
}
