library;

import 'package:yaml/yaml.dart';

/// Converts a [YamlMap] / [YamlList] tree produced by the `yaml` package into
/// plain Dart [Map<String, dynamic>] / [List<dynamic>] so the rest of the
/// plugin system (which expects ordinary Dart collections) can work with it.
dynamic normalizeYaml(dynamic node) {
  if (node is YamlMap) {
    return {
      for (final entry in node.entries)
        entry.key.toString(): normalizeYaml(entry.value),
    };
  }
  if (node is YamlList) {
    return node.map(normalizeYaml).toList();
  }
  // Scalars (String, int, double, bool, null) pass through unchanged.
  return node;
}

/// Parse a YAML string and return a plain [Map<String, dynamic>].
/// Throws [FormatException] if the content is not a YAML mapping.
Map<String, dynamic> parseYamlToMap(String content) {
  final raw = loadYaml(content);
  final normalized = normalizeYaml(raw);
  if (normalized is! Map) {
    throw const FormatException('flutter_config.yaml must be a YAML mapping.');
  }
  return Map<String, dynamic>.from(normalized);
}
