library;

import '../types.dart';

/// User-extensible plugin registry.
///
/// The core package intentionally ships with NO pre-built third-party plugin
/// entries. Every SDK configuration lives in the `generic:` section of
/// `flutter_config.yaml` — users read the SDK docs once and fill in the YAML.
///
/// If you want to create reusable named plugins for your own team, register
/// them here:
///
/// ```dart
/// // In your app's config setup code:
/// pluginRegistry['my-sdk'] = (props) => withMySdk(
///   apiKey: props['apiKey'] as String,
/// );
/// ```
///
/// Then reference them in flutter_config.yaml:
/// ```yaml
/// plugins:
///   - name: my-sdk
///     props:
///       apiKey: ${MY_SDK_API_KEY}
/// ```
final Map<String, ConfigPlugin Function(Map<String, dynamic> props)> pluginRegistry = {};

/// Apply a named plugin from [pluginRegistry].
///
/// Prints a warning and returns [config] unchanged if [name] is not found.
ConfigPlugin withStaticPlugin(String name, [Map<String, dynamic>? props]) {
  return (config) {
    final factory = pluginRegistry[name];
    if (factory == null) {
      // ignore: avoid_print
      print('[flutter_config] Warning: plugin "$name" not found in registry. '
          'Register it in pluginRegistry or use the generic: section instead.');
      return config;
    }
    return factory(props ?? {})(config);
  };
}
