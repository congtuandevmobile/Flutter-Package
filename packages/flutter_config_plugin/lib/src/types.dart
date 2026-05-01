/// Core type definitions for flutter_config_plugin.
/// Mirrors the architecture of @expo/config-plugins.
library;

// ---------------------------------------------------------------------------
// ConfigPlugin
// ---------------------------------------------------------------------------

/// A config plugin: a function that receives a [FlutterConfig] and returns a
/// modified [FlutterConfig]. Plugins are composed via [withPlugins].
typedef ConfigPlugin = FlutterConfig Function(FlutterConfig config);

/// A plugin factory: a function that accepts props and returns a [ConfigPlugin].
/// Use this when a plugin needs parameterisation:
///   final myPlugin = configPluginFactory((config) => ..., name: 'myPlugin');
typedef ConfigPluginFactory<T> = ConfigPlugin Function(T props);

// ---------------------------------------------------------------------------
// Mods
// ---------------------------------------------------------------------------

/// An async modifier function that processes a specific file type.
/// It receives [ExportedConfig] (containing parsed file data in [modResults]),
/// may mutate [modResults], and must return an [ExportedConfig].
typedef ConfigMod = Future<ExportedConfig> Function(ExportedConfig props);

// ---------------------------------------------------------------------------
// FlutterConfig
// ---------------------------------------------------------------------------

/// The root configuration object passed through every plugin and mod.
/// Equivalent to ExpoConfig in @expo/config-plugins.
class FlutterConfig {
  const FlutterConfig({
    required this.name,
    this.bundleIdentifier,
    this.applicationId,
    this.version = '1.0.0',
    Map<String, Map<String, ConfigMod>>? mods,
    InternalConfig? internal,
  })  : mods = mods ?? const {},
        internal = internal ?? const InternalConfig();

  /// App display name.
  final String name;

  /// iOS bundle identifier (e.g. com.example.app).
  final String? bundleIdentifier;

  /// Android application ID (e.g. com.example.app).
  final String? applicationId;

  final String version;

  /// Registered mods, keyed by platform then mod-name.
  /// e.g. `mods['ios']['infoPlist'] = <ConfigMod>`
  final Map<String, Map<String, ConfigMod>> mods;

  /// Internal book-keeping (plugin history, introspection results).
  final InternalConfig internal;

  FlutterConfig copyWith({
    String? name,
    String? bundleIdentifier,
    String? applicationId,
    String? version,
    Map<String, Map<String, ConfigMod>>? mods,
    InternalConfig? internal,
  }) {
    return FlutterConfig(
      name: name ?? this.name,
      bundleIdentifier: bundleIdentifier ?? this.bundleIdentifier,
      applicationId: applicationId ?? this.applicationId,
      version: version ?? this.version,
      mods: mods ?? this.mods,
      internal: internal ?? this.internal,
    );
  }

  /// Returns a new config with [mod] registered at [platform][modName].
  /// The previous mod (if any) is accessible via [ExportedConfig.nextMod].
  FlutterConfig withRegisteredMod(
      String platform, String modName, ConfigMod mod) {
    final platformMods =
        Map<String, ConfigMod>.from(mods[platform] ?? const {});
    platformMods[modName] = mod;
    final newMods = Map<String, Map<String, ConfigMod>>.from(mods);
    newMods[platform] = platformMods;
    return copyWith(mods: newMods);
  }

  @override
  String toString() =>
      'FlutterConfig(name: $name, bundleId: $bundleIdentifier, appId: $applicationId, v$version)';
}

// ---------------------------------------------------------------------------
// ExportedConfig – props passed to each mod during execution
// ---------------------------------------------------------------------------

/// The value flowing through the mod execution chain.
/// [modResults] holds the parsed file data for the current mod type.
class ExportedConfig {
  const ExportedConfig({
    required this.config,
    required this.modResults,
    required this.modRequest,
  });

  final FlutterConfig config;

  /// Parsed representation of the file being processed.
  /// Type depends on the mod: `Map<String,dynamic>` for plists/XML,
  /// String for raw-text mods (Podfile, Gradle), etc.
  final dynamic modResults;

  final ModRequest modRequest;

  ExportedConfig copyWith({
    FlutterConfig? config,
    dynamic modResults,
    ModRequest? modRequest,
  }) {
    return ExportedConfig(
      config: config ?? this.config,
      modResults: modResults ?? this.modResults,
      modRequest: modRequest ?? this.modRequest,
    );
  }
}

// ---------------------------------------------------------------------------
// ModRequest – execution context for a single mod invocation
// ---------------------------------------------------------------------------

class ModRequest {
  const ModRequest({
    required this.projectRoot,
    required this.platformProjectRoot,
    required this.platform,
    required this.modName,
    this.introspect = false,
    this.nextMod,
  });

  /// Root of the Flutter project (contains pubspec.yaml).
  final String projectRoot;

  /// Root of the platform sub-project (e.g. `<root>/ios` or `<root>/android`).
  final String platformProjectRoot;

  /// 'ios' or 'android'.
  final String platform;

  /// Name of the mod being executed (e.g. 'infoPlist', 'manifest').
  final String modName;

  /// When true, mods should read files but not write them back.
  final bool introspect;

  /// The next mod in the chain (the one registered before this one).
  final ConfigMod? nextMod;

  ModRequest copyWith({
    ConfigMod? nextMod,
    bool? introspect,
  }) {
    return ModRequest(
      projectRoot: projectRoot,
      platformProjectRoot: platformProjectRoot,
      platform: platform,
      modName: modName,
      introspect: introspect ?? this.introspect,
      nextMod: nextMod ?? this.nextMod,
    );
  }
}

// ---------------------------------------------------------------------------
// InternalConfig
// ---------------------------------------------------------------------------

class InternalConfig {
  const InternalConfig({
    this.modResults = const {},
    this.pluginHistory = const {},
  });

  /// Results of introspection runs, keyed by platform then mod-name.
  final Map<String, Map<String, dynamic>> modResults;

  /// History of executed plugins (used by [withRunOnce]).
  final Map<String, PluginHistoryItem> pluginHistory;

  InternalConfig copyWith({
    Map<String, Map<String, dynamic>>? modResults,
    Map<String, PluginHistoryItem>? pluginHistory,
  }) {
    return InternalConfig(
      modResults: modResults ?? this.modResults,
      pluginHistory: pluginHistory ?? this.pluginHistory,
    );
  }
}

class PluginHistoryItem {
  const PluginHistoryItem({required this.name, this.version});

  final String name;
  final String? version;
}

// ---------------------------------------------------------------------------
// Mod execution order constants (used by compileModsAsync)
// ---------------------------------------------------------------------------

const modPrecedences = {
  'ios': {'dangerous': -2, 'xcodeproj': -1, 'finalized': 1},
  'android': {'dangerous': -1, 'finalized': 1},
};
