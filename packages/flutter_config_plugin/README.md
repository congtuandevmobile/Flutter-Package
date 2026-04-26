# Flutter Config Plugin

A Dart library inspired by Expo Config Plugins, designed to read and modify native project configuration files (`Info.plist`, `AndroidManifest.xml`, `.pbxproj`, etc.) programmatically. This is particularly useful for building CLI tools, scripts, or Flutter packages that need to automatically set up native platform configurations.

## Features

- **iOS Configs**: Read and modify `Info.plist`, `.entitlements`, and Xcode project settings (`.pbxproj`).
- **Android Configs**: Read and modify `AndroidManifest.xml`, `build.gradle`, `strings.xml`, `colors.xml`, etc.
- **Cross-Platform**: Update bundle identifiers, application names, permissions, and other native metadata.

## Installation

Add this to your package's `pubspec.yaml` (or link it locally):

```yaml
dependencies:
  flutter_config_plugin:
    path: ../flutter_config_plugin # Or git/pub depending on your setup
```

## How It Works

This plugin operates directly on the configuration files (like XML files for Android or text files like `.pbxproj` for iOS). 
Instead of spinning up native environments, it uses targeted RegExp manipulation to parse and modify configuration blocks efficiently. 
This allows it to run entirely in pure Dart and execute extremely fast.

## Usage Guide

Here are some common examples of how to use this plugin to manipulate iOS and Android configurations.

### iOS

#### Modifying `Info.plist`

You can use the helper `getInfoPlistPathFromPbxproj` to dynamically find the correct `Info.plist` file, even if it's placed inside a custom target.

```dart
import 'package:flutter_config_plugin/flutter_config_plugin.dart';

Future<void> updateInfoPlist(String projectRoot) async {
  // Find and load the Info.plist file. 
  // You can optionally filter by targetName if your project has multiple targets (e.g. App Clips).
  final plistPath = await getInfoPlistPathFromPbxproj(
    projectRoot, 
    buildConfiguration: 'Release', 
    targetName: 'Runner'
  ) ?? 'ios/Runner/Info.plist';
  
  final plist = await InfoPlist.load(plistPath);

  // Set properties
  plist.setProperty('NSCameraUsageDescription', 'This app requires camera access.');
  plist.setProperty('UIRequiresFullScreen', true);

  // Save the changes back to the file
  await plist.save();
}
```

#### Modifying `.pbxproj` Build Settings

You can dynamically search and update specific targets or configurations inside Xcode.

```dart
import 'package:flutter_config_plugin/flutter_config_plugin.dart';

Future<void> updateXcodeProject(String projectRoot) async {
  final project = await resolvePathOrProject(projectRoot);
  if (project == null) return;

  // Set the Bundle Identifier across all build configurations globally
  project.productBundleIdentifier = 'com.example.myapp';

  // Set iOS Deployment Target
  project.deploymentTarget = '13.0';

  // Read a custom build property for a specific target
  final existingPlist = project.getBuildProperty(
    'INFOPLIST_FILE', 
    buildName: 'Debug', 
    targetName: 'Runner'
  );

  // Set custom build properties for a specific configuration
  project.setBuildProperty('ENABLE_BITCODE', 'NO', buildName: 'Release');

  // Update target attributes (e.g., Development Team)
  project.setTargetAttribute('DevelopmentTeam', 'ABC1234567');

  // Add Known Regions for localization
  project.addKnownRegion('fr');

  await project.save();
}
```

#### Modifying Entitlements

```dart
import 'package:flutter_config_plugin/flutter_config_plugin.dart';

Future<void> updateEntitlements(String projectRoot) async {
  final entitlementsPath = 'ios/Runner/Runner.entitlements';
  final entitlements = await Entitlements.load(entitlementsPath);

  entitlements.setProperty('aps-environment', 'production');
  await entitlements.save();
}
```

### Android

#### Modifying `AndroidManifest.xml`

```dart
import 'package:flutter_config_plugin/flutter_config_plugin.dart';

Future<void> updateManifest(String projectRoot) async {
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final manifest = await AndroidManifest.load(manifestPath);

  // Add a permission
  manifest.addPermission('android.permission.INTERNET');
  manifest.addPermission('android.permission.CAMERA');

  // Update application attributes
  manifest.setAppAttribute('android:allowBackup', 'false');

  // Add metadata inside <application>
  manifest.addMetaData('com.google.firebase.messaging.default_notification_channel_id', 'high_importance_channel');

  await manifest.save();
}
```

#### Modifying URI Schemes (Deep Links)

You can easily append a custom URI scheme to your Android application.

```dart
import 'package:flutter_config_plugin/flutter_config_plugin.dart';

// Use it inside a plugin pipeline:
ConfigPlugin withMyScheme() {
  return (config) {
    // This will automatically find the correct intent-filter or create one 
    // and inject <data android:scheme="myapp" />
    return withAndroidScheme('myapp')(config);
  };
}
```

#### Modifying `strings.xml`

```dart
import 'package:flutter_config_plugin/flutter_config_plugin.dart';

Future<void> updateStrings(String projectRoot) async {
  final stringsPath = 'android/app/src/main/res/values/strings.xml';
  final strings = await AndroidStrings.load(stringsPath);

  strings.setString('app_name', 'My Awesome App');
  strings.setString('custom_key', 'Custom Value');

  await strings.save();
}
```

## Known Limitations & Differences from Expo Config Plugins

- **Regex-based Parsing:** The `XcodeProject` (.pbxproj) parser relies on Dart regular expressions rather than generating a full abstract syntax tree (AST). 
- **Unsupported Xcode Actions:** Because it doesn't parse into an object-oriented AST (like the `xcode` Node package used by Expo), complex Xcode file tree operations such as `addResourceFileToGroup`, `ensureGroupRecursively`, or `addFramework` are not currently supported out of the box. You can only manipulate strings inside Build Settings, Target Attributes, and basic text replacements.

## License

MIT
