library;

import '../types.dart';
import '../with_plugins.dart';
import '../utils/env_resolver.dart';
import 'static_plugins.dart';
import 'generic_config.dart';

/// Applies the full `flutter_config.yaml` payload expressed as a plain Dart map.
///
/// Typical call sites:
/// ```dart
/// // From the CLI (bin/flutter_config.dart) after YAML parsing:
/// final rawMap = parseYamlToMap(configFileContent);
/// config = withDynamicConfig(rawMap)(config);
/// ```
///
/// Map shape expected:
/// ```yaml
/// app:          # optional – overrides FlutterConfig fields
///   name: My App
///   bundleIdentifier: com.example.app
///   applicationId: com.example.app
///   version: 1.0.0
///
/// plugins:      # named plugins from the registry
///   - name: facebook
///     props:
///       appId: ${FACEBOOK_APP_ID}
///       clientToken: ${FACEBOOK_CLIENT_TOKEN}
///       displayName: My App
///   - name: transistorsoft-location
///     props:
///       licenseKey: ${TRANSISTORSOFT_LICENSE_KEY}
///
/// generic:      # arbitrary native-file modifications (see withGenericConfig)
///   ios:
///     infoPlist:
///       TSLocationManagerLicense: ${TRANSISTORSOFT_LICENSE_KEY}
///     backgroundModes: [location, fetch]
///     urlSchemes:
///       - role: Editor
///         schemes: [fb${FACEBOOK_APP_ID}]
///   android:
///     permissions:
///       - android.permission.INTERNET
///     strings:
///       - name: facebook_app_id
///         value: ${FACEBOOK_APP_ID}
///     manifest:
///       application:
///         meta-data:
///           - name: com.google.android.geo.API_KEY
///             value: ${GOOGLE_MAPS_API_KEY}
/// ```
ConfigPlugin withDynamicConfig(Map<String, dynamic> rawConfig) {
  return (config) {
    // Resolve ${VAR} placeholders in the entire map before doing anything else.
    final resolved = resolveEnv(rawConfig) as Map<String, dynamic>;

    final plugins = <ConfigPlugin>[];

    // ── Named plugins from registry ──────────────────────────────────────────
    final pluginList = resolved['plugins'] as List?;
    if (pluginList != null) {
      for (final item in pluginList) {
        if (item is String) {
          // - name (no props)
          plugins.add(withStaticPlugin(item));
        } else if (item is Map) {
          // - name: facebook
          //   props:
          //     appId: ...
          final name = item['name']?.toString();
          if (name != null) {
            plugins.add(withStaticPlugin(
                name, item['props'] as Map<String, dynamic>?));
          }
        } else if (item is List && item.length >= 2) {
          // Legacy array format: [name, {props}]
          plugins.add(withStaticPlugin(
              item[0].toString(), item[1] as Map<String, dynamic>?));
        }
      }
    }

    // ── Generic native-file modifications ────────────────────────────────────
    final generic = resolved['generic'] as Map<String, dynamic>?;
    if (generic != null) {
      plugins.add(withGenericConfig(generic));
    }

    return withPlugins(config, plugins);
  };
}
