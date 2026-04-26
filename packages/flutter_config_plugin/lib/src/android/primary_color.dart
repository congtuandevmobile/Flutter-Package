library;

import '../types.dart';
import '../with_mod.dart';
import 'resources.dart';

// ---------------------------------------------------------------------------
// withAndroidPrimaryColor
// ---------------------------------------------------------------------------

/// Set the primary color in colors.xml (colorPrimary key).
ConfigPlugin withAndroidPrimaryColor(String hexColor) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'colors',
        action: (props) async {
          final doc = props.modResults!;
          setColorItem(doc, 'colorPrimary', hexColor);
          return props.copyWith(modResults: doc);
        },
      );
}

/// Set multiple colors in colors.xml.
ConfigPlugin withAndroidColors(Map<String, String> colors) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'colors',
        action: (props) async {
          final doc = props.modResults!;
          for (final entry in colors.entries) {
            setColorItem(doc, entry.key, entry.value);
          }
          return props.copyWith(modResults: doc);
        },
      );
}

String? getPrimaryColor(dynamic doc) {
  if (doc == null) return null;
  return getColorItem(doc, 'colorPrimary');
}
