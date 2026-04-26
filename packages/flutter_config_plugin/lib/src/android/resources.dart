library;

import 'package:xml/xml.dart';

// ---------------------------------------------------------------------------
// strings.xml helpers
// ---------------------------------------------------------------------------

/// Return the text value of a `<string name="[key]">` in strings.xml.
String? getStringItem(XmlDocument doc, String key) =>
    doc.rootElement
        .findElements('string')
        .where((el) => el.getAttribute('name') == key)
        .firstOrNull
        ?.innerText;

/// Add or update a `<string>` entry in strings.xml.
void setStringItem(XmlDocument doc, String key, String value,
    {bool translatable = true}) {
  removeStringItem(doc, key);
  final el = XmlElement(XmlName('string'));
  el.setAttribute('name', key);
  if (!translatable) el.setAttribute('translatable', 'false');
  el.children.add(XmlText(escapeAndroidString(value)));
  doc.rootElement.children.add(el);
}

/// Remove a `<string>` entry by name.
void removeStringItem(XmlDocument doc, String key) {
  doc.rootElement.children.removeWhere((node) =>
      node is XmlElement &&
      node.name.local == 'string' &&
      node.getAttribute('name') == key);
}

// ---------------------------------------------------------------------------
// colors.xml helpers
// ---------------------------------------------------------------------------

String? getColorItem(XmlDocument doc, String key) =>
    doc.rootElement
        .findElements('color')
        .where((el) => el.getAttribute('name') == key)
        .firstOrNull
        ?.innerText;

void setColorItem(XmlDocument doc, String key, String value) {
  removeColorItem(doc, key);
  final el = XmlElement(XmlName('color'));
  el.setAttribute('name', key);
  el.children.add(XmlText(value));
  doc.rootElement.children.add(el);
}

void removeColorItem(XmlDocument doc, String key) {
  doc.rootElement.children.removeWhere((node) =>
      node is XmlElement &&
      node.name.local == 'color' &&
      node.getAttribute('name') == key);
}

// ---------------------------------------------------------------------------
// Android string escaping
// ---------------------------------------------------------------------------

/// Escape special characters in Android string resources.
String escapeAndroidString(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '\\"')
    .replaceAll("'", "\\'");

/// Unescape an Android string resource value.
String unescapeAndroidString(String value) => value
    .replaceAll('\\"', '"')
    .replaceAll("\\'", "'")
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');
