library;

import 'dart:io';
import 'package:path/path.dart' as p;

// In-memory overlay: values loaded from .env file take precedence over
// Platform.environment, but are overridden by actual CI environment vars
// when the same key exists in Platform.environment.
final _dotEnvOverrides = <String, String>{};

/// Load a `.env` file from [projectRoot] and store its values.
///
/// Call this once at startup before any [resolveEnvString] calls.
/// - In **dev**: reads `.env` → populates [_dotEnvOverrides].
/// - In **CI** (GitLab, GitHub Actions, etc.): environment variables are
///   already injected by the CI runner into [Platform.environment], so no
///   .env file is needed and this is a no-op if the file doesn't exist.
///
/// Priority order (highest → lowest):
///   1. [Platform.environment]  ← CI variables always win
///   2. [_dotEnvOverrides]      ← .env file (dev only)
void loadDotEnv(String projectRoot) {
  final file = File(p.join(projectRoot, '.env'));
  if (!file.existsSync()) return;

  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    final eqIdx = line.indexOf('=');
    if (eqIdx == -1) continue;

    final key = line.substring(0, eqIdx).trim();
    var value = line.substring(eqIdx + 1).trim();

    // Strip surrounding quotes: "value" or 'value'
    if (value.length >= 2) {
      final first = value[0];
      final last = value[value.length - 1];
      if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
        value = value.substring(1, value.length - 1);
      }
    }

    _dotEnvOverrides[key] = value;
  }
}

/// Resolves `${VAR}` placeholders in [value].
///
/// Lookup order:
///   1. [Platform.environment]  – real CI/shell env var
///   2. [_dotEnvOverrides]      – .env file loaded by [loadDotEnv]
///   3. Empty string             – variable not found anywhere
String resolveEnvString(String value) {
  final regex = RegExp(r'\$\{(\w+)\}');
  return value.replaceAllMapped(regex, (match) {
    final key = match.group(1)!;
    return Platform.environment[key] ?? _dotEnvOverrides[key] ?? '';
  });
}

/// Recursively resolves `${VAR}` in any JSON-like structure (Map, List, String).
dynamic resolveEnv(dynamic data) {
  if (data is String) return resolveEnvString(data);
  if (data is List) return data.map(resolveEnv).toList();
  if (data is Map) {
    return Map<String, dynamic>.fromEntries(
      data.entries.map((e) => MapEntry(e.key.toString(), resolveEnv(e.value))),
    );
  }
  return data;
}
