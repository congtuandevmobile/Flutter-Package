library;

import 'package:path/path.dart' as p;

import 'types.dart';
import 'ios/ios_base_mods.dart';
import 'android/android_base_mods.dart';

/// Options for [compileModsAsync].
class CompileModsOptions {
  const CompileModsOptions({
    required this.projectRoot,
    this.platforms = const ['ios', 'android'],
    this.introspect = false,
  });

  final String projectRoot;
  final List<String> platforms;

  /// If true, files are read and parsed but NOT written back to disk.
  /// Results are stored in [FlutterConfig.internal.modResults].
  final bool introspect;
}

/// Execute all registered mods, reading and writing native files as needed.
/// Equivalent to expo's `compileModsAsync`.
///
/// Steps:
/// 1. Add platform base mods (file providers) if not already present.
/// 2. Sort mods by precedence (dangerous first, finalized last).
/// 3. Invoke each mod's provider chain.
Future<FlutterConfig> compileModsAsync(
  FlutterConfig config,
  CompileModsOptions options,
) async {
  // Attach base mod providers for each requested platform.
  for (final platform in options.platforms) {
    if (platform == 'ios') {
      config = withIosBaseMods(config, options.projectRoot);
    } else if (platform == 'android') {
      config = withAndroidBaseMods(config, options.projectRoot);
    }
  }

  return _evalModsAsync(config, options);
}

Future<FlutterConfig> _evalModsAsync(
  FlutterConfig config,
  CompileModsOptions options,
) async {
  for (final platform in options.platforms) {
    final platformMods = config.mods[platform] ?? {};
    if (platformMods.isEmpty) continue;

    final platformProjectRoot = p.join(options.projectRoot, platform);
    final precedence = modPrecedences[platform] ?? {};

    // Sort: lower precedence value runs first.
    final sortedEntries = platformMods.entries.toList()
      ..sort((a, b) {
        final pa = precedence[a.key] ?? 0;
        final pb = precedence[b.key] ?? 0;
        return pa.compareTo(pb);
      });

    for (final entry in sortedEntries) {
      final modName = entry.key;
      final mod = entry.value;

      final request = ModRequest(
        projectRoot: options.projectRoot,
        platformProjectRoot: platformProjectRoot,
        platform: platform,
        modName: modName,
        introspect: options.introspect,
      );

      final initial = ExportedConfig(
        config: config,
        modResults: null,
        modRequest: request,
      );

      final result = await mod(initial);
      config = result.config;

      // In introspect mode, save parsed results for inspection.
      if (options.introspect && result.modResults != null) {
        final platformResults =
            Map<String, dynamic>.from(config.internal.modResults[platform] ?? {});
        platformResults[modName] = result.modResults;
        final allResults =
            Map<String, Map<String, dynamic>>.from(config.internal.modResults);
        allResults[platform] = platformResults;
        config = config.copyWith(
          internal: config.internal.copyWith(modResults: allResults),
        );
      }
    }
  }

  return config;
}

/// Read all native config files without modifying them.
/// Useful for previewing current state.
Future<FlutterConfig> introspectModsAsync(
  FlutterConfig config,
  String projectRoot, {
  List<String> platforms = const ['ios', 'android'],
}) async {
  return compileModsAsync(
    config,
    CompileModsOptions(
      projectRoot: projectRoot,
      platforms: platforms,
      introspect: true,
    ),
  );
}
