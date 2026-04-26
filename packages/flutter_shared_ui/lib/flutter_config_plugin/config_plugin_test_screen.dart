import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_config_plugin/flutter_config_plugin.dart';
import 'package:path/path.dart' as p;

/// Demonstrates the flutter_config_plugin pipeline.
///
/// Each card shows:
///   • The plugin(s) being applied
///   • A "Dry run" result (no files written)
///   • An "Apply" button to write changes to the actual native files
class ConfigPluginTestScreen extends StatefulWidget {
  const ConfigPluginTestScreen({super.key});

  @override
  State<ConfigPluginTestScreen> createState() => _ConfigPluginTestScreenState();
}

class _ConfigPluginTestScreenState extends State<ConfigPluginTestScreen> {
  // Resolve the Flutter project root relative to the running app's location.
  // Works for `flutter run` inside apps/flutter_package.
  String get _projectRoot {
    final exe = Platform.resolvedExecutable;
    // Walk up until we find a pubspec.yaml for the app package.
    var dir = Directory(p.dirname(exe));
    for (var i = 0; i < 10; i++) {
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    // Fallback: assume running from workspace root.
    return p.join(p.dirname(exe), '..', '..', '..', 'apps', 'flutter_package');
  }

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  final List<_PluginDemo> _demos = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _buildDemos();
  }

  void _buildDemos() {
    _demos
      ..clear()
      ..addAll([
        _PluginDemo(
          title: 'withDisplayName',
          description: 'Sets CFBundleDisplayName in Info.plist',
          platform: 'iOS',
          buildPlugin: () => withDisplayName('MyFlutterApp (Plugin)'),
        ),
        _PluginDemo(
          title: 'withIosPermission – Camera',
          description: 'Adds NSCameraUsageDescription to Info.plist',
          platform: 'iOS',
          buildPlugin: () => withIosPermission(
            key: 'NSCameraUsageDescription',
            description: 'Used for scanning QR codes',
          ),
        ),
        _PluginDemo(
          title: 'withIosPermission – Location',
          description:
              'Adds NSLocationWhenInUseUsageDescription to Info.plist',
          platform: 'iOS',
          buildPlugin: () => withIosPermission(
            key: 'NSLocationWhenInUseUsageDescription',
            description: 'Needed to show your position on the map',
          ),
        ),
        _PluginDemo(
          title: 'withArbitraryLoads',
          description:
              'Sets NSAppTransportSecurity.NSAllowsArbitraryLoads = true',
          platform: 'iOS',
          buildPlugin: () => withArbitraryLoads(true),
        ),
        _PluginDemo(
          title: 'withAndroidPermission – Camera',
          description:
              'Adds <uses-permission android:name="android.permission.CAMERA"/> to AndroidManifest.xml',
          platform: 'Android',
          buildPlugin: () =>
              withAndroidPermission('android.permission.CAMERA'),
        ),
        _PluginDemo(
          title: 'withAndroidPermission – Internet',
          description:
              'Adds INTERNET permission to AndroidManifest.xml',
          platform: 'Android',
          buildPlugin: () =>
              withAndroidPermission('android.permission.INTERNET'),
        ),
        _PluginDemo(
          title: 'withAndroidAppLabel',
          description: 'Sets app_name string in strings.xml',
          platform: 'Android',
          buildPlugin: () => withAndroidAppLabel('MyFlutterApp'),
        ),
        _PluginDemo(
          title: 'Combined pipeline (withPlugins)',
          description:
              'iOS: displayName + camera permission\nAndroid: camera permission + app label',
          platform: 'Both',
          buildPlugin: () => (FlutterConfig c) => withPlugins(c, [
                withDisplayName('CombinedApp'),
                withIosPermission(
                    key: 'NSCameraUsageDescription',
                    description: 'QR scanner'),
                withAndroidPermission('android.permission.CAMERA'),
                withAndroidAppLabel('CombinedApp'),
              ]),
        ),
      ]);
  }

  // ---------------------------------------------------------------------------
  // Dry-run
  // ---------------------------------------------------------------------------

  Future<String> _dryRun(_PluginDemo demo) async {
    var config = FlutterConfig(
      name: 'flutter_package',
      bundleIdentifier: 'com.example.flutterPackage',
      applicationId: 'com.example.flutter_package',
    );
    config = demo.buildPlugin()(config);

    final buf = StringBuffer();

    // iOS mods
    if (config.mods['ios']?.isNotEmpty == true) {
      buf.writeln('── iOS mods registered ──');
      for (final key in config.mods['ios']!.keys) {
        buf.writeln('  • $key');
      }

      // Simulate Info.plist changes by applying to a fake plist.
      if (config.mods['ios']!.containsKey('infoPlist')) {
        final fakePlist = <String, dynamic>{
          'CFBundleDisplayName': 'flutter_package',
          'CFBundleVersion': '1',
          'CFBundleShortVersionString': '1.0',
        };
        final mod = config.mods['ios']!['infoPlist']!;
        final request = ModRequest(
          projectRoot: _projectRoot,
          platformProjectRoot: p.join(_projectRoot, 'ios'),
          platform: 'ios',
          modName: 'infoPlist',
          introspect: true,
        );
        final result = await mod(ExportedConfig(
          config: config,
          modResults: fakePlist,
          modRequest: request,
        ));
        buf.writeln('\nInfo.plist preview:');
        final out = result.modResults as Map<String, dynamic>;
        for (final e in out.entries) {
          buf.writeln('  ${e.key}: ${e.value}');
        }
      }
    }

    // Android mods
    if (config.mods['android']?.isNotEmpty == true) {
      buf.writeln('\n── Android mods registered ──');
      for (final key in config.mods['android']!.keys) {
        buf.writeln('  • $key');
      }
    }

    return buf.isEmpty ? '(no mods registered)' : buf.toString().trimRight();
  }

  // ---------------------------------------------------------------------------
  // Apply to disk
  // ---------------------------------------------------------------------------

  Future<void> _applyToDisk(_PluginDemo demo) async {
    setState(() => _loading = true);
    try {
      var config = FlutterConfig(
        name: 'flutter_package',
        bundleIdentifier: 'com.example.flutterPackage',
        applicationId: 'com.example.flutter_package',
      );
      config = demo.buildPlugin()(config);

      final platforms = <String>[];
      if (config.mods['ios']?.isNotEmpty == true) platforms.add('ios');
      if (config.mods['android']?.isNotEmpty == true) platforms.add('android');

      await compileModsAsync(
        config,
        CompileModsOptions(
          projectRoot: _projectRoot,
          platforms: platforms,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Applied "${demo.title}" to native files'),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Config Plugin'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Like @expo/config-plugins – but for Flutter',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _demos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _DemoCard(
                demo: _demos[i],
                onDryRun: () => _dryRun(_demos[i]),
                onApply: () => _applyToDisk(_demos[i]),
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _PluginDemo {
  _PluginDemo({
    required this.title,
    required this.description,
    required this.platform,
    required this.buildPlugin,
  });

  final String title;
  final String description;
  final String platform; // 'iOS' | 'Android' | 'Both'
  final ConfigPlugin Function() buildPlugin;
}

// ---------------------------------------------------------------------------
// Card widget
// ---------------------------------------------------------------------------

class _DemoCard extends StatefulWidget {
  const _DemoCard({
    required this.demo,
    required this.onDryRun,
    required this.onApply,
  });

  final _PluginDemo demo;
  final Future<String> Function() onDryRun;
  final Future<void> Function() onApply;

  @override
  State<_DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<_DemoCard> {
  String? _previewText;
  bool _running = false;

  Color get _platformColor {
    switch (widget.demo.platform) {
      case 'iOS':
        return Colors.blue.shade700;
      case 'Android':
        return Colors.green.shade700;
      default:
        return Colors.purple.shade700;
    }
  }

  Future<void> _runDryRun() async {
    setState(() {
      _running = true;
      _previewText = null;
    });
    try {
      final result = await widget.onDryRun();
      setState(() => _previewText = result);
    } catch (e) {
      setState(() => _previewText = 'Error: $e');
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _platformColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.demo.platform,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.demo.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.demo.description,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 10),

            // Preview area
            if (_previewText != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  _previewText!,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.5),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _running ? null : _runDryRun,
                    icon: _running
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.preview, size: 16),
                    label:
                        Text(_previewText == null ? 'Dry Run' : 'Re-run'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onApply(),
                    icon: const Icon(Icons.build, size: 16),
                    label: const Text('Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _platformColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
