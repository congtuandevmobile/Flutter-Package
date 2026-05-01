library;

import 'dart:io';
import 'package:xml/xml.dart';

/// Read an XML file and return its parsed [XmlDocument].
Future<XmlDocument> readXmlAsync(String filePath) async {
  final contents = await File(filePath).readAsString();
  return XmlDocument.parse(contents);
}

/// Write an [XmlDocument] to a file, pretty-printed.
Future<void> writeXmlAsync(String filePath, XmlDocument doc) async {
  await File(filePath).writeAsString(
    '${doc.toXmlString(pretty: true, indent: '    ')}\n',
  );
}

/// Find the first child element with [name] inside [parent], or null.
XmlElement? findElement(XmlElement parent, String name) =>
    parent.findElements(name).firstOrNull;

/// Find or create a child element with [name] inside [parent].
XmlElement findOrCreateElement(XmlElement parent, String name) {
  return parent.findElements(name).firstOrNull ??
      (parent..children.add(XmlElement(XmlName(name))))
          .findElements(name)
          .first;
}

/// Return the text content of the first element matching [name] inside
/// [parent], or null if not found.
String? getElementText(XmlElement parent, String name) =>
    findElement(parent, name)?.innerText;

/// Set (or create) a text-content child element.
void setElementText(XmlElement parent, String name, String value) {
  final el = findOrCreateElement(parent, name);
  el.children
    ..clear()
    ..add(XmlText(value));
}
