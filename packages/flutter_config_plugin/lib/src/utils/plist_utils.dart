library;

/// Minimal XML-plist parser/writer for Flutter's Info.plist (Apple XML format).
/// Does not support binary plists.

import 'package:xml/xml.dart';

/// Parse an XML plist string into a Dart Map.
Map<String, dynamic> parsePlist(String contents) {
  final doc = XmlDocument.parse(contents);
  final plistEl = doc.findElements('plist').firstOrNull;
  if (plistEl == null) throw FormatException('Not a plist document');
  final dict = plistEl.findElements('dict').firstOrNull;
  if (dict == null) return {};
  return _parseDict(dict);
}

/// Serialise a Dart Map back to XML plist format.
String buildPlist(Map<String, dynamic> data) {
  final buffer = StringBuffer();
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln(
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
  buffer.writeln('<plist version="1.0">');
  _writeDict(buffer, data, indent: 0);
  buffer.writeln('</plist>');
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _parseDict(XmlElement dict) {
  final result = <String, dynamic>{};
  final children =
      dict.childElements.toList();
  for (var i = 0; i < children.length - 1; i += 2) {
    if (children[i].name.local != 'key') continue;
    final key = children[i].innerText;
    result[key] = _parseValue(children[i + 1]);
  }
  return result;
}

dynamic _parseValue(XmlElement el) {
  switch (el.name.local) {
    case 'dict':
      return _parseDict(el);
    case 'array':
      return el.childElements.map(_parseValue).toList();
    case 'string':
      return el.innerText;
    case 'integer':
      return int.parse(el.innerText);
    case 'real':
      return double.parse(el.innerText);
    case 'true':
      return true;
    case 'false':
      return false;
    case 'data':
      return el.innerText.trim();
    default:
      return el.innerText;
  }
}

void _writeDict(StringBuffer buf, Map<String, dynamic> map, {required int indent}) {
  final pad = '\t' * indent;
  buf.writeln('$pad<dict>');
  for (final entry in map.entries) {
    buf.writeln('$pad\t<key>${_esc(entry.key)}</key>');
    _writeValue(buf, entry.value, indent: indent + 1);
  }
  buf.writeln('$pad</dict>');
}

void _writeValue(StringBuffer buf, dynamic value, {required int indent}) {
  final pad = '\t' * indent;
  if (value is Map<String, dynamic>) {
    _writeDict(buf, value, indent: indent);
  } else if (value is List) {
    buf.writeln('$pad<array>');
    for (final item in value) {
      _writeValue(buf, item, indent: indent + 1);
    }
    buf.writeln('$pad</array>');
  } else if (value is bool) {
    buf.writeln('$pad<${value ? 'true' : 'false'}/>');
  } else if (value is int) {
    buf.writeln('$pad<integer>$value</integer>');
  } else if (value is double) {
    buf.writeln('$pad<real>$value</real>');
  } else {
    buf.writeln('$pad<string>${_esc(value.toString())}</string>');
  }
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
