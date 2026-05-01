library;

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

// ─── DESCRIPTOR ──────────────────────────────────────────────────────────────

/// Descriptor shipped inside a Flutter package to declare that it requires
/// native-file configuration via flutter_config_plugin.
///
/// A package adds a file called `flutter_config_plugin.json` at its root:
///
/// ```json
/// {
///   "pluginName": "my-sdk",
///   "description": "My SDK native config",
///   "requiredEnvVars": ["MY_SDK_LICENSE_KEY"],
///   "optionalEnvVars": ["MY_SDK_ENDPOINT"],
///   "docs": "https://example.com/setup"
/// }
/// ```
///
/// When the CLI detects this file it prints a reminder so the developer knows
/// what to add to their `flutter_config.yaml` / `.env`.
class PackagePluginDescriptor {
  const PackagePluginDescriptor({
    required this.packageName,
    required this.pluginName,
    this.description,
    this.requiredEnvVars = const [],
    this.optionalEnvVars = const [],
    this.docs,
  });

  /// The pub package name (e.g. `flutter_background_geolocation`).
  final String packageName;

  /// The plugin name to use in `flutter_config.yaml` (e.g. `transistorsoft-location`).
  final String pluginName;

  final String? description;

  /// Env vars / props that MUST be supplied.
  final List<String> requiredEnvVars;

  /// Env vars / props that are optional.
  final List<String> optionalEnvVars;

  /// Link to setup docs.
  final String? docs;

  @override
  String toString() => 'PackagePluginDescriptor($packageName → $pluginName)';
}

// ─── DISCOVERY ───────────────────────────────────────────────────────────────

/// Scans all packages listed in `.dart_tool/package_config.json` and returns
/// descriptors for every package that ships a `flutter_config_plugin.json`
/// file at its root.
///
/// Call from the CLI before [compileModsAsync] to print helpful reminders.
List<PackagePluginDescriptor> discoverPackagePlugins(String projectRoot) {
  final configFile =
      File(p.join(projectRoot, '.dart_tool', 'package_config.json'));
  if (!configFile.existsSync()) {
    stderr.writeln(
        '[flutter_config] Warning: .dart_tool/package_config.json not found. '
        'Run `flutter pub get` first.');
    return [];
  }

  final raw =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final packages = (raw['packages'] as List?) ?? [];

  final descriptors = <PackagePluginDescriptor>[];

  for (final pkg in packages.cast<Map<String, dynamic>>()) {
    final pkgName = pkg['name'] as String? ?? '';
    final rootUri = pkg['rootUri'] as String? ?? '';
    if (pkgName.isEmpty || rootUri.isEmpty) continue;

    // rootUri can be relative (e.g. "../../packages/foo") or absolute.
    final Uri resolvedUri;
    try {
      final base = Uri.file(p.join(projectRoot, '.dart_tool', 'x'));
      resolvedUri = base.resolve(rootUri);
    } catch (_) {
      continue;
    }

    final pkgRoot = resolvedUri.toFilePath();
    final descriptorFile =
        File(p.join(pkgRoot, 'flutter_config_plugin.json'));
    if (!descriptorFile.existsSync()) continue;

    try {
      final json =
          jsonDecode(descriptorFile.readAsStringSync()) as Map<String, dynamic>;
      descriptors.add(PackagePluginDescriptor(
        packageName: pkgName,
        pluginName: json['pluginName'] as String? ?? pkgName,
        description: json['description'] as String?,
        requiredEnvVars: List<String>.from(json['requiredEnvVars'] as List? ?? []),
        optionalEnvVars: List<String>.from(json['optionalEnvVars'] as List? ?? []),
        docs: json['docs'] as String?,
      ));
    } catch (e) {
      stderr.writeln(
          '[flutter_config] Warning: Could not parse flutter_config_plugin.json '
          'in $pkgName: $e');
    }
  }

  return descriptors;
}

/// Prints a human-readable summary of discovered package plugins.
/// Returns true if any required env vars are missing (so CLI can exit non-zero
/// when [failOnMissing] is set).
bool printDiscoveryReport(
  List<PackagePluginDescriptor> descriptors, {
  bool failOnMissing = false,
  Map<String, String> env = const {},
}) {
  if (descriptors.isEmpty) return false;

  // Use actual environment if caller doesn't provide override.
  final effectiveEnv = env.isEmpty ? Platform.environment : env;

  stdout.writeln('');
  stdout.writeln('┌─ flutter_config_plugin: detected packages ───────────────');

  var anyMissing = false;

  for (final d in descriptors) {
    stdout.writeln('│');
    stdout.writeln('│  📦 ${d.packageName}  →  plugin: "${d.pluginName}"');
    if (d.description != null) stdout.writeln('│     ${d.description}');
    if (d.docs != null) stdout.writeln('│     docs: ${d.docs}');

    for (final v in d.requiredEnvVars) {
      final present = effectiveEnv.containsKey(v);
      final icon = present ? '✅' : '❌';
      stdout.writeln('│     $icon  $v  (required)');
      if (!present) anyMissing = true;
    }
    for (final v in d.optionalEnvVars) {
      final present = effectiveEnv.containsKey(v);
      final icon = present ? '✅' : '⚠️ ';
      stdout.writeln('│     $icon  $v  (optional)');
    }
  }

  stdout.writeln('│');
  stdout.writeln('└──────────────────────────────────────────────────────────');
  stdout.writeln('');

  return anyMissing && failOnMissing;
}
