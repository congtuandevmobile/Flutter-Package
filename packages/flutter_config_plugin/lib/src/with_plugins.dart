library;

import 'types.dart';

/// Apply a list of [plugins] to [config] sequentially (left-to-right).
///
/// Each element can be:
///   - A [ConfigPlugin] function
///   - A `[ConfigPlugin, props]` list (not used when using the Dart factory pattern)
///
/// Equivalent to expo's `withPlugins`.
FlutterConfig withPlugins(
  FlutterConfig config,
  List<ConfigPlugin> plugins,
) {
  return plugins.fold(config, (prev, plugin) => plugin(prev));
}

/// Wrap a plugin so it only runs once, tracked by [name].
/// Subsequent calls with the same name are no-ops.
/// Equivalent to expo's `withRunOnce`.
FlutterConfig withRunOnce(
  FlutterConfig config, {
  required String name,
  String? version,
  required ConfigPlugin plugin,
}) {
  if (config.internal.pluginHistory.containsKey(name)) {
    return config;
  }
  final history = Map<String, PluginHistoryItem>.from(config.internal.pluginHistory);
  history[name] = PluginHistoryItem(name: name, version: version);
  config = config.copyWith(
    internal: config.internal.copyWith(pluginHistory: history),
  );
  return plugin(config);
}

/// Helper that wraps a [plugin] so it only runs once per config lifecycle.
ConfigPlugin createRunOncePlugin(
  ConfigPlugin plugin, {
  required String name,
  String? version,
}) {
  return (config) => withRunOnce(
        config,
        name: name,
        version: version,
        plugin: plugin,
      );
}
