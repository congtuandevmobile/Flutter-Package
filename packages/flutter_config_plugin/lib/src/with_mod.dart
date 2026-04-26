library;

import 'types.dart';

/// Register [action] as a modifier for [platform]/[modName] on [config].
///
/// The previously registered mod (if any) is available inside [action] via
/// `props.modRequest.nextMod`.  This creates a middleware chain:
///
///   provider (reads file)
///     → mod added first
///       → mod added second  ← [action] runs here, calls nextMod to go deeper
///         → …
///
/// Equivalent to expo's `withMod`.
FlutterConfig withMod(
  FlutterConfig config, {
  required String platform,
  required String modName,
  required ConfigMod action,
}) {
  final existing = config.mods[platform]?[modName];

  // Intercepting mod wraps [action] so that the previous chain is accessible
  // as nextMod, and automatically executes the chain.
  Future<ExportedConfig> interceptingMod(ExportedConfig props) async {
    ExportedConfig result = props;
    if (existing != null) {
      result = await existing(props);
    }
    return action(
      result.copyWith(
        modRequest: result.modRequest.copyWith(nextMod: existing),
      ),
    );
  }

  return config.withRegisteredMod(platform, modName, interceptingMod);
}

/// Register a mod that runs before all others for [platform].
/// Equivalent to expo's `withDangerousMod`.
FlutterConfig withDangerousMod(
  FlutterConfig config, {
  required String platform,
  required ConfigMod action,
}) {
  return withMod(config, platform: platform, modName: 'dangerous', action: action);
}

/// Register a mod that runs after all others for [platform].
/// Equivalent to expo's `withFinalizedMod`.
FlutterConfig withFinalizedMod(
  FlutterConfig config, {
  required String platform,
  required ConfigMod action,
}) {
  return withMod(config, platform: platform, modName: 'finalized', action: action);
}
