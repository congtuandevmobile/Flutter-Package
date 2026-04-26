library;

/// Aggregates warnings produced during plugin execution.
/// Warnings are informational – they don't stop the build.
class WarningAggregator {
  WarningAggregator._();

  static final List<String> _ios = [];
  static final List<String> _android = [];
  static final List<String> _global = [];

  static void addWarningIos(String tag, String message) =>
      _ios.add('[iOS][$tag] $message');

  static void addWarningAndroid(String tag, String message) =>
      _android.add('[Android][$tag] $message');

  static void addWarning(String message) => _global.add(message);

  static List<String> get iosWarnings => List.unmodifiable(_ios);
  static List<String> get androidWarnings => List.unmodifiable(_android);
  static List<String> get globalWarnings => List.unmodifiable(_global);

  static List<String> get allWarnings =>
      [..._global, ..._ios, ..._android];

  static void clear() {
    _ios.clear();
    _android.clear();
    _global.clear();
  }

  static void printWarnings() {
    for (final w in allWarnings) {
      // ignore: avoid_print
      print('⚠️  $w');
    }
  }
}

/// Convenience top-level helpers (mirrors expo API).
void addWarningIos(String tag, String message) =>
    WarningAggregator.addWarningIos(tag, message);

void addWarningAndroid(String tag, String message) =>
    WarningAggregator.addWarningAndroid(tag, message);
