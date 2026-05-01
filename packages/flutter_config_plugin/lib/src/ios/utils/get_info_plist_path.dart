library;

import 'xcodeproj.dart';

/// Find the Info.plist path linked to a specific build configuration by
/// reading `INFOPLIST_FILE` from the xcodeproj build settings.
///
/// Mirrors expo's `getInfoPlistPath.ts → getInfoPlistPathFromPbxproj`.
///
/// [projectRootOrProject]: either the iOS project root directory (String) or
///   an already-loaded [XcodeProject].
///
/// [buildConfiguration]: defaults to `'Release'`.
///
/// Returns the path relative to the project root (e.g. `Runner/Info.plist`),
/// or null if not found.
Future<String?> getInfoPlistPathFromPbxproj(
  dynamic projectRootOrProject, {
  String buildConfiguration = 'Release',
  String? targetName,
}) async {
  final project = await resolvePathOrProject(projectRootOrProject);
  if (project == null) return null;

  final raw = project.getBuildProperty(
    'INFOPLIST_FILE',
    buildName: buildConfiguration,
    targetName: targetName,
  );
  return _sanitizeInfoPlistBuildProperty(raw);
}

/// Sanitize a raw INFOPLIST_FILE build setting value.
///
/// Removes surrounding quotes and strips the `$(SRCROOT)` prefix.
String? _sanitizeInfoPlistBuildProperty(String? infoPlist) {
  if (infoPlist == null) return null;
  return infoPlist.replaceAll('"', '').replaceAll(r'$(SRCROOT)', '').replaceAll(r'$(SRCROOT)/', '');
}
