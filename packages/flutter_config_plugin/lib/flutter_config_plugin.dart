/// Flutter Config Plugin – a composable pipeline for modifying iOS and Android
/// native project files, inspired by @expo/config-plugins.
///
/// ## Quick start
///
/// ```dart
/// import 'package:flutter_config_plugin/flutter_config_plugin.dart';
///
/// void main() async {
///   var config = const FlutterConfig(
///     name: 'MyApp',
///     bundleIdentifier: 'com.example.myapp',
///     applicationId: 'com.example.myapp',
///   );
///
///   config = withPlugins(config, [
///     // iOS
///     withDisplayName('My Awesome App'),
///     withBundleIdentifier('com.example.myapp'),
///     withDeploymentTarget('14.0'),
///     withIosPermission(key: IosPermissions.camera, description: 'QR scanner'),
///     withAssociatedDomains(['applinks:example.com']),
///
///     // Android
///     withAndroidPermission(AndroidPermissions.camera),
///     withAndroidName('My Awesome App'),
///     withAndroidVersion(versionName: '1.0.0', versionCode: 1),
///   ]);
///
///   await compileModsAsync(
///     config,
///     CompileModsOptions(projectRoot: '/path/to/flutter/project'),
///   );
/// }
/// ```
library;

// Core pipeline
export 'src/types.dart';
export 'src/with_plugins.dart';
export 'src/with_mod.dart';
export 'src/mod_compiler.dart';

// Utilities
export 'src/utils/errors.dart';
export 'src/utils/warnings.dart';
export 'src/utils/generate_code.dart';
export 'src/utils/plist_utils.dart';
export 'src/utils/xml_utils.dart';

// ── iOS ──────────────────────────────────────────────────────────────────────

export 'src/ios/ios_config_types.dart';
export 'src/ios/ios_base_mods.dart';
export 'src/ios/paths.dart';
export 'src/ios/utils/xcodeproj.dart';
export 'src/ios/utils/string.dart';
export 'src/ios/utils/get_info_plist_path.dart';

// iOS plist modules
export 'src/ios/info_plist_helpers.dart';
export 'src/ios/bundle_identifier.dart';
export 'src/ios/name.dart'
    hide setDisplayName, setName; // avoid clash with android/name.dart
export 'src/ios/version.dart';
export 'src/ios/orientation.dart';
export 'src/ios/permissions.dart';
export 'src/ios/scheme.dart';
export 'src/ios/device_family.dart';
export 'src/ios/requires_full_screen.dart';
export 'src/ios/uses_non_exempt_encryption.dart';
export 'src/ios/locales.dart' hide writeLocaleFiles;
export 'src/ios/google.dart'; // withIosGoogleServicesFile
export 'src/ios/maps.dart' hide getGoogleMapsApiKey;
export 'src/ios/privacy_info.dart';
export 'src/ios/entitlements.dart';
export 'src/ios/app_transport_security.dart';

// iOS xcodeproj modules
export 'src/ios/deployment_target.dart';
export 'src/ios/development_team.dart';
export 'src/ios/bitcode.dart';
export 'src/ios/build_properties.dart' hide readPodfileProperties;
export 'src/ios/provisioning_profile.dart';

// ── Android ──────────────────────────────────────────────────────────────────

export 'src/android/android_base_mods.dart';
export 'src/android/android_plugins.dart'
    hide withAndroidPermission, withAndroidPermissionMaxSdk, withAndroidAppLabel; // re-exported individually
export 'src/android/manifest_helpers.dart';
export 'src/android/resources.dart';
export 'src/android/properties.dart';
export 'src/android/paths.dart';

// Android modules
export 'src/android/allow_backup.dart' hide getAllowBackupFromManifest;
export 'src/android/permissions.dart';
export 'src/android/name.dart';
export 'src/android/version.dart';
export 'src/android/package.dart';
export 'src/android/orientation.dart';
export 'src/android/primary_color.dart';
export 'src/android/system_bars.dart';
export 'src/android/window_soft_input_mode.dart';
export 'src/android/predictive_back_gesture.dart';
export 'src/android/intent_filters.dart';
export 'src/android/scheme.dart';
export 'src/android/google_maps_api_key.dart';
export 'src/android/google_services.dart';
export 'src/android/build_properties.dart';
export 'src/android/locales.dart';

// ── Dynamic & Registry ───────────────────────────────────────────────────────

export 'src/plugins/static_plugins.dart';
export 'src/plugins/dynamic_config.dart';
export 'src/plugins/generic_config.dart';
export 'src/plugins/package_discovery.dart';
export 'src/utils/env_resolver.dart';
export 'src/utils/yaml_utils.dart';
