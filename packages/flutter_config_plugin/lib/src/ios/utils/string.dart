library;

/// Remove surrounding double-quotes from a pbxproj string value.
///
/// `'"Runner"'` → `'Runner'`
String trimQuotes(String s) {
  if (s.isEmpty) return s;
  if (s[0] == '"' && s[s.length - 1] == '"') return s.substring(1, s.length - 1);
  return s;
}

/// Remove surrounding double-quotes (alias of [trimQuotes], matching expo's `unquote`).
String unquote(dynamic value) {
  if (value is num) return value.toString();
  final s = value.toString();
  return trimQuotes(s);
}
