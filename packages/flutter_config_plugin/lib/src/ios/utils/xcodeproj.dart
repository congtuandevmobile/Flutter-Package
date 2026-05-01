library;

import 'dart:io';
import 'package:path/path.dart' as p;

import 'string.dart';

/// Represents a parsed .pbxproj file.
///
/// Rather than implementing a full OpenStep plist parser (like the `xcode` npm
/// package used by expo) we store the raw file content and expose targeted
/// string-manipulation helpers for the build-setting operations that
/// iOS config-plugin modules need.
class XcodeProject {
  XcodeProject._(this.filepath, this._content);

  /// Path to the .pbxproj file.
  final String filepath;
  String _content;

  /// Raw .pbxproj text (may have been modified in-memory).
  String get contents => _content;

  // --------------------------------------------------------------------------
  // Factory
  // --------------------------------------------------------------------------

  static Future<XcodeProject> load(String pbxprojPath) async {
    final content = await File(pbxprojPath).readAsString();
    return XcodeProject._(pbxprojPath, content);
  }

  static XcodeProject fromContents(String filepath, String content) =>
      XcodeProject._(filepath, content);

  // --------------------------------------------------------------------------
  // Persist
  // --------------------------------------------------------------------------

  Future<void> save() async {
    await File(filepath).writeAsString(_content);
  }

  // --------------------------------------------------------------------------
  // Build settings – set / remove / get
  // --------------------------------------------------------------------------

  /// Set [key] = [value] in XCBuildConfiguration buildSettings blocks.
  ///
  /// When [buildName] is null, all configurations (Debug, Release, Profile)
  /// are updated.  Pass `buildName: 'Release'` to update only one.
  void setBuildProperty(String key, String value, {String? buildName}) {
    if (buildName != null) {
      _setBuildPropertyForConfig(key, value, buildName);
    } else {
      for (final name in ['Debug', 'Release', 'Profile']) {
        _setBuildPropertyForConfig(key, value, name);
      }
    }
  }

  void _setBuildPropertyForConfig(String key, String value, String configName) {
    final blockRe = RegExp(
      r'\{[^{}]*isa\s*=\s*XCBuildConfiguration[^{}]*\}',
      dotAll: true,
    );
    _content = _content.replaceAllMapped(blockRe, (m) {
      final block = m[0]!;
      if (!RegExp('name\\s*=\\s*$configName\\s*;').hasMatch(block)) return block;
      return _setKeyInBuildSettingsBlock(block, key, value);
    });
  }

  String _setKeyInBuildSettingsBlock(String block, String key, String value) {
    final settingsRe = RegExp(
      r'(buildSettings\s*=\s*\{)([^}]*?)(\s*\})',
      dotAll: true,
    );
    return block.replaceFirstMapped(settingsRe, (m) {
      var settings = m[2]!;
      final keyRe = RegExp('$key\\s*=\\s*[^;]+;');
      final quoted = _needsQuoting(value) ? '"$value"' : value;
      if (keyRe.hasMatch(settings)) {
        settings = settings.replaceFirst(keyRe, '$key = $quoted;');
      } else {
        settings += '\n\t\t\t\t$key = $quoted;';
      }
      return '${m[1]}$settings${m[3]}';
    });
  }

  /// Remove [key] from build configurations.
  void removeBuildProperty(String key, {String? buildName}) {
    final keyRe = RegExp('\\t*$key\\s*=\\s*[^;]+;\\n?');
    if (buildName != null) {
      final blockRe = RegExp(
        r'\{[^{}]*isa\s*=\s*XCBuildConfiguration[^{}]*\}',
        dotAll: true,
      );
      _content = _content.replaceAllMapped(blockRe, (m) {
        final block = m[0]!;
        if (!RegExp('name\\s*=\\s*$buildName\\s*;').hasMatch(block)) {
          return block;
        }
        return block.replaceAll(keyRe, '');
      });
    } else {
      _content = _content.replaceAll(keyRe, '');
    }
  }

  /// Read the first occurrence of [key] in any buildSettings block.
  ///
  /// If [targetName] is provided, it specifically searches within that target's
  /// build configurations.
  /// Returns the value without surrounding quotes.
  String? getBuildProperty(String key, {String? buildName, String? targetName}) {
    if (targetName != null) {
      final targetRe = RegExp(
          r'isa\s*=\s*PBXNativeTarget;[\s\S]*?buildConfigurationList\s*=\s*([0-9A-F]+)[^;]*;[\s\S]*?(?:name|productName)\s*=\s*"?\s*' +
              targetName +
              r'\s*"?\s*;');
      final targetMatch = targetRe.firstMatch(_content);
      if (targetMatch != null) {
        final configListId = targetMatch[1]!;
        final listRe = RegExp(
            configListId + r'[^\{]*\{[\s\S]*?buildConfigurations\s*=\s*\(([^)]*)\)');
        final listMatch = listRe.firstMatch(_content);
        if (listMatch != null) {
          final configs = listMatch[1]!
              .replaceAll(RegExp(r'/\*.*?\*/'), '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          for (final configId in configs) {
            final configBlockRe = RegExp(
                configId + r'[^\{]*\{([\s\S]*?isa\s*=\s*XCBuildConfiguration;[\s\S]*?)\}');
            final configBlockMatch = configBlockRe.firstMatch(_content);
            if (configBlockMatch != null) {
              final block = configBlockMatch[1]!;
              if (buildName == null ||
                  RegExp('name\\s*=\\s*"?$buildName"?\\s*;').hasMatch(block)) {
                final settingsRe = RegExp(r'buildSettings\s*=\s*\{([^}]*?)\}');
                final settingsMatch = settingsRe.firstMatch(block);
                if (settingsMatch != null) {
                  final keyMatch = RegExp('$key\\s*=\\s*([^;]+);').firstMatch(settingsMatch[1]!);
                  if (keyMatch != null) return unquote(keyMatch[1]!.trim());
                }
              }
            }
          }
        }
      }
      return null;
    }

    final settingsRe = RegExp(
      r'buildSettings\s*=\s*\{([^}]*?)\}',
      dotAll: true,
    );
    for (final m in settingsRe.allMatches(_content)) {
      final settings = m[1]!;
      if (buildName != null) {
        final startIdx = m.start;
        final surroundingBlock = _content.substring(
            (startIdx - 800).clamp(0, _content.length), startIdx);
        if (!RegExp('name\\s*=\\s*$buildName\\s*;').hasMatch(surroundingBlock)) {
          continue;
        }
      }
      final match = RegExp('$key\\s*=\\s*([^;]+);').firstMatch(settings);
      if (match != null) {
        return unquote(match[1]!.trim());
      }
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // Convenience property accessors
  // --------------------------------------------------------------------------

  String? get productBundleIdentifier =>
      getBuildProperty('PRODUCT_BUNDLE_IDENTIFIER');

  set productBundleIdentifier(String? value) {
    if (value != null) setBuildProperty('PRODUCT_BUNDLE_IDENTIFIER', value);
  }

  String? get deploymentTarget =>
      getBuildProperty('IPHONEOS_DEPLOYMENT_TARGET');

  set deploymentTarget(String? value) {
    if (value != null) setBuildProperty('IPHONEOS_DEPLOYMENT_TARGET', value);
  }

  String? get swiftVersion => getBuildProperty('SWIFT_VERSION');

  /// Get the product name.
  ///
  /// Resolves `$(TARGET_NAME)` variables by looking at the first native
  /// target's productName.
  String? getProductName() {
    // Try PRODUCT_NAME build setting first.
    String? name = getBuildProperty('PRODUCT_NAME');
    if (name != null && name != r'$(TARGET_NAME)') return unquote(name);

    // Fall back to the first native target's productName field.
    final targetProductName =
        RegExp(r'isa\s*=\s*PBXNativeTarget[^}]*?productName\s*=\s*([^;]+);',
                dotAll: true)
            .firstMatch(_content)?[1];
    return targetProductName != null ? unquote(targetProductName.trim()) : null;
  }

  // --------------------------------------------------------------------------
  // TargetAttributes
  // --------------------------------------------------------------------------

  /// Set a single target attribute (e.g. DevelopmentTeam, ProvisioningStyle).
  void setTargetAttribute(String key, String value) {
    final attrRe = RegExp(r'TargetAttributes\s*=\s*\{[^}]*?\}', dotAll: true);
    _content = _content.replaceFirstMapped(attrRe, (m) {
      var block = m[0]!;
      final keyRe = RegExp('$key\\s*=\\s*[^;]+;');
      final quoted = _needsQuoting(value) ? '"$value"' : value;
      if (keyRe.hasMatch(block)) {
        block = block.replaceFirst(keyRe, '$key = $quoted;');
      } else {
        block = block.replaceFirst(RegExp(r'(\{)'), '{\n\t\t\t\t$key = $quoted;');
      }
      return block;
    });
  }

  // --------------------------------------------------------------------------
  // knownRegions
  // --------------------------------------------------------------------------

  void addKnownRegion(String region) {
    if (_content.contains('"$region"') || _content.contains(' $region ')) return;
    _content = _content.replaceFirstMapped(
      RegExp(r'(knownRegions\s*=\s*\()([^)]*?)(\s*\))'),
      (m) => '${m[1]}${m[2]}\n\t\t\t$region,${m[3]}',
    );
  }

  // --------------------------------------------------------------------------
  // productName
  // --------------------------------------------------------------------------

  void updateProductName(String name) {
    _content = _content.replaceAllMapped(
      RegExp(r'productName\s*=\s*[^;]+;'),
      (_) => 'productName = "$name";',
    );
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  static bool _needsQuoting(String value) =>
      value.contains(' ') ||
      value.contains('/') ||
      value.contains('(') ||
      value.contains(')');
}

// ---------------------------------------------------------------------------
// resolveXcodeBuildSetting
// ---------------------------------------------------------------------------
// Port of expo's Xcodeproj.ts `resolveXcodeBuildSetting`.
// Handles $(VAR) and $(VAR:modifier) patterns.

/// Resolve a pbxproj build-setting value that may contain `$(VARIABLE)` or
/// `$(VARIABLE:modifier)` references.
///
/// [lookup] should return the value for a given build setting name.
///
/// Supported modifiers: `lower`, `upper`, `suffix`, `file`, `dir`, `base`,
/// `rfc1034identifier`, `c99extidentifier`, `standardizepath`, `default=...`
String resolveXcodeBuildSetting(
  String value,
  String? Function(String buildSetting) lookup,
) {
  // Match $(VAR) or $(VAR:mod1:mod2)
  final parsed = value.replaceAllMapped(
    RegExp(r'\$\(([^()]*|\([^)]*\))\)'),
    (match) {
      final inner = match[1]!;
      final parts = inner.split(':');
      final variable = parts[0];
      final transformations = parts.skip(1).toList();

      String? lookedUp = lookup(variable);
      if (lookedUp != null) {
        lookedUp = resolveXcodeBuildSetting(lookedUp, lookup);
      }
      String? resolved = lookedUp;

      for (final modifier in transformations) {
        switch (modifier) {
          case 'lower':
            resolved = resolved?.toLowerCase();
          case 'upper':
            resolved = resolved?.toUpperCase();
          case 'suffix':
            if (resolved != null) resolved = p.extension(resolved);
          case 'file':
            if (resolved != null) resolved = p.basename(resolved);
          case 'dir':
            if (resolved != null) resolved = p.dirname(resolved);
          case 'base':
            if (resolved != null) {
              final base = p.basename(resolved);
              final ext = p.extension(base);
              resolved = ext.isEmpty ? base : base.substring(0, base.length - ext.length);
            }
          case 'rfc1034identifier':
            resolved = resolved?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-');
          case 'c99extidentifier':
            resolved = resolved?.replaceAll(RegExp(r'[-\s]'), '_');
          case 'standardizepath':
            if (resolved != null) resolved = p.normalize(resolved);
          default:
            // Handle `default=VALUE`
            final defaultMatch = RegExp(r'^default=(.*)$').firstMatch(modifier);
            if (defaultMatch != null && resolved == null) {
              resolved = defaultMatch[1];
            }
        }
      }

      return resolveXcodeBuildSetting(resolved ?? '', lookup);
    },
  );

  // If the substitution changed the value, resolve again (handles nested vars).
  if (parsed != value) {
    return resolveXcodeBuildSetting(parsed, lookup);
  }
  return value;
}

// ---------------------------------------------------------------------------
// Path helpers
// ---------------------------------------------------------------------------

/// Locate the .pbxproj file under [iosRoot].
String getPbxprojPath(String iosRoot) {
  final xcodeproj = Directory(iosRoot)
      .listSync()
      .whereType<Directory>()
      .where((d) => d.path.endsWith('.xcodeproj'))
      .firstOrNull;
  if (xcodeproj == null) {
    throw StateError('No .xcodeproj directory found in $iosRoot');
  }
  return p.join(xcodeproj.path, 'project.pbxproj');
}

/// Sanitize a name for use in Xcode project names.
///
/// Mirrors expo's `sanitizedName`: removes non-word characters, strips
/// Unicode combining marks.
String sanitizedName(String name) {
  // Remove non-word chars (keeps letters, digits; removes underscores too for
  // project names to stay clean like expo does).
  String result = name.replaceAll(RegExp(r'[\W_]+', unicode: true), '');
  // Strip ASCII diacritical mark range (approximation without full NFD).
  result = result.replaceAll(RegExp(r'[̀-ͯ]'), '');
  return result.isNotEmpty ? result : 'app';
}

/// Return the project name from the first .xcodeproj directory name.
String? getProjectName(String iosRoot) {
  final xcodeproj = Directory(iosRoot)
      .listSync()
      .whereType<Directory>()
      .where((d) => d.path.endsWith('.xcodeproj'))
      .firstOrNull;
  if (xcodeproj == null) return null;
  return p.basenameWithoutExtension(xcodeproj.path);
}

/// Load and return an [XcodeProject] for [projectRoot].
Future<XcodeProject?> getPbxproj(String projectRoot) async {
  try {
    final path = getPbxprojPath(p.join(projectRoot, 'ios'));
    return XcodeProject.load(path);
  } catch (_) {
    return null;
  }
}

/// Resolve path-or-project: if a String is passed, load the project; if an
/// [XcodeProject] is already available, return it.
Future<XcodeProject?> resolvePathOrProject(
    dynamic projectRootOrProject) async {
  if (projectRootOrProject is XcodeProject) return projectRootOrProject;
  if (projectRootOrProject is String) return getPbxproj(projectRootOrProject);
  return null;
}
