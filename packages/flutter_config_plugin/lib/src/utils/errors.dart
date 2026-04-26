library;

/// Error codes for config plugin failures.
enum ConfigPluginErrorCode {
  invalidPluginType,
  invalidPluginImport,
  pluginNotFound,
  conflictingProvider,
  invalidModOrder,
  missingProvider,
  fileNotFound,
  invalidFormat,
}

/// Error thrown by the config plugin system.
class ConfigPluginError extends Error {
  ConfigPluginError(
    this.message, {
    this.code,
    this.cause,
  });

  final String message;
  final ConfigPluginErrorCode? code;
  final Object? cause;

  @override
  String toString() {
    final buf = StringBuffer('ConfigPluginError: $message');
    if (code != null) buf.write(' [${code!.name}]');
    if (cause != null) buf.write('\n  Caused by: $cause');
    return buf.toString();
  }
}

/// Throw a [ConfigPluginError] with an optional [code].
Never throwConfigPluginError(
  String message, {
  ConfigPluginErrorCode? code,
  Object? cause,
}) {
  throw ConfigPluginError(message, code: code, cause: cause);
}
