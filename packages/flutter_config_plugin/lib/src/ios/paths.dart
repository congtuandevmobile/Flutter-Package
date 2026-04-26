library;

import 'dart:io';
import 'package:path/path.dart' as p;

import 'utils/xcodeproj.dart';

/// Locate the iOS Runner Info.plist.
String getInfoPlistPath(String iosRoot, {String projectName = 'Runner'}) =>
    p.join(iosRoot, projectName, 'Info.plist');

/// Locate the iOS AppDelegate file (Swift preferred, falls back to ObjC).
String? getAppDelegateFilePath(String iosRoot, {String projectName = 'Runner'}) {
  final swift = p.join(iosRoot, projectName, 'AppDelegate.swift');
  if (File(swift).existsSync()) return swift;
  final objc = p.join(iosRoot, projectName, 'AppDelegate.m');
  if (File(objc).existsSync()) return objc;
  return null;
}

/// Locate the Podfile.
String getPodfilePath(String iosRoot) => p.join(iosRoot, 'Podfile');

/// Locate the Podfile.properties.json.
String getPodfilePropertiesPath(String iosRoot) =>
    p.join(iosRoot, 'Podfile.properties.json');

/// Locate the entitlements file.
String? getEntitlementsFilePath(String iosRoot, {String projectName = 'Runner'}) {
  final path = p.join(iosRoot, projectName, '$projectName.entitlements');
  if (File(path).existsSync()) return path;
  return null;
}

/// Locate the .pbxproj file.
String getPBXProjectPath(String iosRoot) => getPbxprojPath(iosRoot);

/// Find all scheme files under [iosRoot].
List<String> findSchemePaths(String iosRoot) {
  final schemesDir = p.join(iosRoot, 'Runner.xcodeproj', 'xcshareddata', 'xcschemes');
  final dir = Directory(schemesDir);
  if (!dir.existsSync()) return [];
  return dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.xcscheme'))
      .map((f) => f.path)
      .toList();
}

/// Return scheme names (without extension).
List<String> findSchemeNames(String iosRoot) =>
    findSchemePaths(iosRoot).map((s) => p.basenameWithoutExtension(s)).toList();
