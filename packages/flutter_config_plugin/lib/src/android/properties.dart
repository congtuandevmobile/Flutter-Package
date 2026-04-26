library;

/// A single line in a gradle.properties file.
sealed class PropertiesItem {
  const PropertiesItem();
}

class PropertyItem extends PropertiesItem {
  const PropertyItem({required this.key, required this.value});
  final String key;
  final String value;
}

class CommentItem extends PropertiesItem {
  const CommentItem(this.comment);
  final String comment;
}

class EmptyLineItem extends PropertiesItem {
  const EmptyLineItem();
}

// ---------------------------------------------------------------------------
// Parse / build
// ---------------------------------------------------------------------------

/// Parse a gradle.properties file into a list of [PropertiesItem].
List<PropertiesItem> parsePropertiesFile(String contents) {
  final items = <PropertiesItem>[];
  for (final line in contents.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      items.add(const EmptyLineItem());
    } else if (trimmed.startsWith('#')) {
      items.add(CommentItem(line));
    } else {
      final eqIdx = line.indexOf('=');
      if (eqIdx < 0) {
        items.add(CommentItem(line));
      } else {
        items.add(PropertyItem(
          key: line.substring(0, eqIdx).trim(),
          value: line.substring(eqIdx + 1).trim(),
        ));
      }
    }
  }
  return items;
}

/// Serialize a list of [PropertiesItem] back to a properties file string.
String propertiesListToString(List<PropertiesItem> items) {
  return items.map((item) {
    if (item is PropertyItem) return '${item.key}=${item.value}';
    if (item is CommentItem) return item.comment;
    return '';
  }).join('\n');
}

/// Get the value of a property by key, or null if not found.
String? getProperty(List<PropertiesItem> items, String key) {
  for (final item in items) {
    if (item is PropertyItem && item.key == key) return item.value;
  }
  return null;
}

/// Add or update a property. Returns the modified list.
List<PropertiesItem> setProperty(
    List<PropertiesItem> items, String key, String value) {
  final idx = items.indexWhere(
      (item) => item is PropertyItem && item.key == key);
  final newItem = PropertyItem(key: key, value: value);
  if (idx >= 0) {
    items[idx] = newItem;
  } else {
    items.add(newItem);
  }
  return items;
}

/// Remove a property by key. Returns the modified list.
List<PropertiesItem> removeProperty(List<PropertiesItem> items, String key) {
  items.removeWhere((item) => item is PropertyItem && item.key == key);
  return items;
}
