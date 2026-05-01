library;

import '../types.dart';
import '../with_mod.dart';
import 'utils/xcodeproj.dart';

// ---------------------------------------------------------------------------
// withDeploymentTarget
// ---------------------------------------------------------------------------

/// Set IPHONEOS_DEPLOYMENT_TARGET in the Xcode project (e.g. "14.0").
ConfigPlugin withDeploymentTarget(String version) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'xcodeproj',
        action: (props) async {
          final project = props.modResults as XcodeProject?;
          if (project == null) return props;
          setDeploymentTargetForBuildConfiguration(project, version);
          return props;
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void setDeploymentTargetForBuildConfiguration(
    XcodeProject project, String version,
    {String? buildName}) {
  project.setBuildProperty('IPHONEOS_DEPLOYMENT_TARGET', version,
      buildName: buildName);
}

String? getDeploymentTarget(XcodeProject project) =>
    project.getBuildProperty('IPHONEOS_DEPLOYMENT_TARGET');
