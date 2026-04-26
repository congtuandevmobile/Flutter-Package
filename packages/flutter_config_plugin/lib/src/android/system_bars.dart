library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

/// Status/navigation bar appearance configuration.
class SystemBarsConfig {
  const SystemBarsConfig({
    this.statusBarTranslucent,
    this.navigationBarColor,
    this.statusBarColor,
    this.windowLightStatusBar,
  });

  final bool? statusBarTranslucent;
  final String? navigationBarColor;
  final String? statusBarColor;
  final bool? windowLightStatusBar;
}

// ---------------------------------------------------------------------------
// withAndroidSystemBars
// ---------------------------------------------------------------------------

/// Configure system bar appearance via `<meta-data>` entries in the manifest.
ConfigPlugin withAndroidSystemBars(SystemBarsConfig config) {
  return (flutterConfig) => withMod(
        flutterConfig,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          final app = getMainApplicationOrThrow(doc);

          if (config.statusBarColor != null) {
            addMetaDataItemToMainApplication(
                app, 'expo.modules.systembar.statusbar_color', config.statusBarColor!);
          }
          if (config.navigationBarColor != null) {
            addMetaDataItemToMainApplication(
                app, 'expo.modules.systembar.navigation_bar_color', config.navigationBarColor!);
          }
          if (config.windowLightStatusBar != null) {
            addMetaDataItemToMainApplication(
                app,
                'expo.modules.systembar.window_light_status_bar',
                config.windowLightStatusBar.toString());
          }

          return props.copyWith(modResults: doc);
        },
      );
}
