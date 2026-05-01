library;

/// Type aliases for iOS configuration maps.
/// Mirror @expo/config-plugins IosConfig.types.ts

/// Represents the contents of Info.plist as a `Map<String, dynamic>`.
typedef InfoPlist = Map<String, dynamic>;

/// Represents the contents of Expo.plist (EAS Updates config).
typedef ExpoPlist = Map<String, dynamic>;

/// Represents a CFBundleURLTypes entry.
class UrlScheme {
  const UrlScheme({
    required this.cfBundleURLSchemes,
    this.cfBundleURLName,
    this.cfBundleURLIconFile,
  });

  final List<String> cfBundleURLSchemes;
  final String? cfBundleURLName;
  final String? cfBundleURLIconFile;

  Map<String, dynamic> toMap() => {
        'CFBundleURLSchemes': cfBundleURLSchemes,
        if (cfBundleURLName != null) 'CFBundleURLName': cfBundleURLName,
        if (cfBundleURLIconFile != null) 'CFBundleURLIconFile': cfBundleURLIconFile,
      };
}

/// Supported interface orientation values.
enum InterfaceOrientation {
  portrait('UIInterfaceOrientationPortrait'),
  portraitUpsideDown('UIInterfaceOrientationPortraitUpsideDown'),
  landscapeLeft('UIInterfaceOrientationLandscapeLeft'),
  landscapeRight('UIInterfaceOrientationLandscapeRight');

  const InterfaceOrientation(this.value);
  final String value;
}

const portraitOrientations = [
  InterfaceOrientation.portrait,
  InterfaceOrientation.portraitUpsideDown,
];

const landscapeOrientations = [
  InterfaceOrientation.landscapeLeft,
  InterfaceOrientation.landscapeRight,
];

const allOrientations = [
  InterfaceOrientation.portrait,
  InterfaceOrientation.portraitUpsideDown,
  InterfaceOrientation.landscapeLeft,
  InterfaceOrientation.landscapeRight,
];

/// App orientation config value.
enum OrientationConfig { portrait, landscape, all }

/// Device family config.
enum DeviceFamilyConfig { handset, tablet, universal }
