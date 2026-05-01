/// flutter_config CLI
///
/// Usage:
///   dart run flutter_config_plugin:flutter_config [project_root] [options]
///
/// Arguments:
///   project_root   Path to the Flutter project (default: current directory).
///
/// Options:
///   --dry-run      Parse and resolve config but do NOT write native files.
///   --check        Print which installed packages need configuration and exit.
///   --no-fail-env  Do not exit with error when required env vars are missing.
///   --platforms    Comma-separated list: ios,android  (default: ios,android)
///
/// Examples:
///   dart run flutter_config_plugin:flutter_config
///   dart run flutter_config_plugin:flutter_config /path/to/app --dry-run
///   dart run flutter_config_plugin:flutter_config --platforms android

import 'dart:io';

import 'package:flutter_config_plugin/flutter_config_plugin.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  // ── Parse arguments ────────────────────────────────────────────────────────
  var projectRoot = Directory.current.path;
  var dryRun = false;
  var checkOnly = false;
  var failOnMissingEnv = true;
  var platforms = ['ios', 'android'];

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--dry-run') {
      dryRun = true;
    } else if (arg == '--check') {
      checkOnly = true;
    } else if (arg == '--no-fail-env') {
      failOnMissingEnv = false;
    } else if (arg.startsWith('--platforms=')) {
      platforms = arg.substring('--platforms='.length).split(',');
    } else if (arg == '--platforms' && i + 1 < args.length) {
      platforms = args[++i].split(',');
    } else if (!arg.startsWith('--')) {
      projectRoot = p.isAbsolute(arg) ? arg : p.join(Directory.current.path, arg);
    }
  }

  // ── Validate project root ──────────────────────────────────────────────────
  if (!Directory(projectRoot).existsSync()) {
    stderr.writeln('❌  Project root not found: $projectRoot');
    exit(1);
  }

  stdout.writeln('🔧  flutter_config — project: $projectRoot');

  // ── 1. Load .env (dev mode) ────────────────────────────────────────────────
  // In CI (GitLab, GitHub Actions, etc.) the runner already injects variables
  // into the process environment, so loadDotEnv is effectively a no-op.
  loadDotEnv(projectRoot);

  // ── 2. Auto-discover installed packages that need config ───────────────────
  final discovered = discoverPackagePlugins(projectRoot);
  final hasMissingEnv = printDiscoveryReport(
    discovered,
    failOnMissing: failOnMissingEnv,
  );
  if (checkOnly) {
    exit(hasMissingEnv ? 1 : 0);
  }
  if (hasMissingEnv) {
    stderr.writeln(
        '❌  Required environment variables are missing. Set them in .env '
        '(dev) or as CI variables (GitLab/GitHub Actions).');
    exit(1);
  }

  // ── 3. Read flutter_config.yaml ────────────────────────────────────────────
  final configFile = File(p.join(projectRoot, 'flutter_config.yaml'));
  if (!configFile.existsSync()) {
    stderr.writeln(
        '❌  flutter_config.yaml not found in $projectRoot\n'
        '    Create it (see README) and re-run.');
    exit(1);
  }

  final Map<String, dynamic> rawConfig;
  try {
    rawConfig = parseYamlToMap(configFile.readAsStringSync());
  } catch (e) {
    stderr.writeln('❌  Failed to parse flutter_config.yaml: $e');
    exit(1);
  }

  // ── 4. Build FlutterConfig from the `app:` section ────────────────────────
  final appSection = rawConfig['app'] as Map<String, dynamic>? ?? {};
  var config = FlutterConfig(
    name: appSection['name']?.toString() ?? 'App',
    bundleIdentifier: appSection['bundleIdentifier']?.toString(),
    applicationId: appSection['applicationId']?.toString(),
    version: appSection['version']?.toString() ?? '1.0.0',
  );

  // ── 5. Apply all plugins from flutter_config.yaml ─────────────────────────
  config = withDynamicConfig(rawConfig)(config);

  // ── 6. Compile (or dry-run) ────────────────────────────────────────────────
  if (dryRun) {
    stdout.writeln('🔍  Dry-run mode — resolving config (no files written)...');
    final result = await introspectModsAsync(
      config,
      projectRoot,
      platforms: platforms,
    );
    _printIntrospectionResult(result);
    stdout.writeln('✅  Dry-run complete.');
    return;
  }

  stdout.writeln('⚙️   Applying to platforms: ${platforms.join(', ')}...');
  try {
    await compileModsAsync(
      config,
      CompileModsOptions(
        projectRoot: projectRoot,
        platforms: platforms,
      ),
    );
  } catch (e, stack) {
    stderr.writeln('❌  Error during compilation:\n$e\n$stack');
    exit(1);
  }

  stdout.writeln('✅  Done. Native files updated:');
  if (platforms.contains('ios')) {
    stdout.writeln('    • ios/Runner/Info.plist');
    stdout.writeln('    • ios/Runner/Runner.entitlements (if changed)');
  }
  if (platforms.contains('android')) {
    stdout.writeln('    • android/app/src/main/AndroidManifest.xml');
    stdout.writeln('    • android/app/src/main/res/values/strings.xml');
  }
}

void _printIntrospectionResult(FlutterConfig config) {
  config.internal.modResults.forEach((platform, mods) {
    stdout.writeln('\n── $platform ─────────────────────────────────');
    mods.forEach((modName, result) {
      stdout.writeln('  [$modName]');
      if (result != null) {
        final preview = result.toString();
        final lines = preview.split('\n').take(20).join('\n');
        stdout.writeln('    ${lines.replaceAll('\n', '\n    ')}');
      }
    });
  });
}
