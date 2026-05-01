library;

import '../types.dart';
import '../with_mod.dart';
import 'resources.dart';

// ---------------------------------------------------------------------------
// withAndroidName
// ---------------------------------------------------------------------------

/// Set the app name in strings.xml (string key "app_name").
ConfigPlugin withAndroidName(String name) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'strings',
        action: (props) async {
          final doc = props.modResults!;
          setStringItem(doc, 'app_name', name, translatable: false);
          return props.copyWith(modResults: doc);
        },
      );
}

/// Convenience alias matching expo's naming.
ConfigPlugin withAndroidAppLabel(String label) => withAndroidName(label);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Sanitize a name for use in Gradle (removes characters that Gradle rejects).
String sanitizeNameForGradle(String name) {
  return name
      .replaceAll(RegExp(r'[\n\r\t]'), '')
      .replaceAll(RegExp(r'[/\\:<>?"*|]'), '_');
}

String? getNameFromStringsXml(dynamic doc) {
  if (doc == null) return null;
  return getStringItem(doc, 'app_name');
}
