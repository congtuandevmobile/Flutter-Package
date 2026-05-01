library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

// ---------------------------------------------------------------------------
// withAllowBackup
// ---------------------------------------------------------------------------

/// Set `android:allowBackup` on the `<application>` element.
/// Defaults to `true` (matching Android default behaviour).
ConfigPlugin withAllowBackup({bool allowBackup = true}) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = _requireDoc(props.modResults);
          final app = getMainApplicationOrThrow(doc);
          setAttribute(app, 'android:allowBackup', allowBackup.toString());
          return props.copyWith(modResults: doc);
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

bool? getAllowBackupFromManifest(dynamic modResults) {
  if (modResults == null) return null;
  final doc = _requireDoc(modResults);
  final app = getMainApplication(doc);
  final val = app?.getAttribute('android:allowBackup');
  if (val == null) return null;
  return val == 'true';
}

dynamic _requireDoc(dynamic modResults) {
  // ignore: avoid_dynamic_calls
  return modResults!;
}
