library;

import 'package:xml/xml.dart';

/// Get the `<application>` element from a parsed AndroidManifest.xml.
XmlElement? getMainApplication(XmlDocument doc) =>
    doc.rootElement.findElements('application').firstOrNull;

XmlElement getMainApplicationOrThrow(XmlDocument doc) {
  final app = getMainApplication(doc);
  if (app == null) throw StateError('<application> not found in AndroidManifest.xml');
  return app;
}

/// Get the first `<activity>` inside `<application>`.
XmlElement? getMainActivity(XmlDocument doc) =>
    getMainApplication(doc)?.findElements('activity').firstOrNull;

XmlElement getMainActivityOrThrow(XmlDocument doc) {
  final act = getMainActivity(doc);
  if (act == null) throw StateError('<activity> not found in AndroidManifest.xml');
  return act;
}

// ---------------------------------------------------------------------------
// Attribute helpers
// ---------------------------------------------------------------------------

String? getAttribute(XmlElement element, String name) =>
    element.getAttribute(name);

void setAttribute(XmlElement element, String name, String value) {
  final existing = element.getAttributeNode(name);
  if (existing != null) {
    existing.value = value;
  } else {
    element.setAttribute(name, value);
  }
}

void removeAttribute(XmlElement element, String name) {
  element.removeAttribute(name);
}

// ---------------------------------------------------------------------------
// <uses-permission>
// ---------------------------------------------------------------------------

/// Check whether a `<uses-permission>` exists at the root of the manifest.
bool hasPermission(XmlDocument doc, String name) => doc.rootElement
    .findElements('uses-permission')
    .any((el) => el.getAttribute('android:name') == name);

/// Add a `<uses-permission>` to the manifest root if not already present.
void addPermission(XmlDocument doc, String name) {
  if (hasPermission(doc, name)) return;
  final el = XmlElement(XmlName('uses-permission'));
  el.setAttribute('android:name', name);
  doc.rootElement.children.insert(0, el);
}

/// Remove a `<uses-permission>` from the manifest root.
void removePermission(XmlDocument doc, String name) {
  doc.rootElement.children.removeWhere((node) =>
      node is XmlElement &&
      node.name.local == 'uses-permission' &&
      node.getAttribute('android:name') == name);
}

// ---------------------------------------------------------------------------
// <meta-data> inside <application>
// ---------------------------------------------------------------------------

XmlElement? getMetaDataItem(XmlElement application, String name) =>
    application
        .findElements('meta-data')
        .where((el) => el.getAttribute('android:name') == name)
        .firstOrNull;

void addMetaDataItemToMainApplication(
    XmlElement application, String name, String value) {
  removeMetaDataItemFromMainApplication(application, name);
  final el = XmlElement(XmlName('meta-data'));
  el.setAttribute('android:name', name);
  el.setAttribute('android:value', value);
  application.children.add(el);
}

void removeMetaDataItemFromMainApplication(
    XmlElement application, String name) {
  application.children.removeWhere((node) =>
      node is XmlElement &&
      node.name.local == 'meta-data' &&
      node.getAttribute('android:name') == name);
}

// ---------------------------------------------------------------------------
// <uses-library>
// ---------------------------------------------------------------------------

void addUsesLibraryItemToMainApplication(
    XmlElement application, {
    required String name,
    bool required = true,
  }) {
  final existing = application
      .findElements('uses-library')
      .any((el) => el.getAttribute('android:name') == name);
  if (existing) return;
  final el = XmlElement(XmlName('uses-library'));
  el.setAttribute('android:name', name);
  el.setAttribute('android:required', required.toString());
  application.children.add(el);
}

void removeUsesLibraryItemFromMainApplication(
    XmlElement application, String name) {
  application.children.removeWhere((node) =>
      node is XmlElement &&
      node.name.local == 'uses-library' &&
      node.getAttribute('android:name') == name);
}
