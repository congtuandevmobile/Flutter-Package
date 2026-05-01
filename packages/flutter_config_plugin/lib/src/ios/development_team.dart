library;

import '../types.dart';
import '../with_mod.dart';
import 'utils/xcodeproj.dart';

// ---------------------------------------------------------------------------
// withDevelopmentTeam
// ---------------------------------------------------------------------------

/// Set DEVELOPMENT_TEAM in all Xcode build configurations.
ConfigPlugin withDevelopmentTeam(String teamId) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'xcodeproj',
        action: (props) async {
          final project = props.modResults as XcodeProject?;
          if (project == null) return props;
          updateDevelopmentTeamForPbxproj(project, teamId);
          return props;
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void updateDevelopmentTeamForPbxproj(XcodeProject project, String teamId) {
  project.setBuildProperty('DEVELOPMENT_TEAM', teamId);
  // Also update TargetAttributes.
  project.setTargetAttribute('DevelopmentTeam', teamId);
}

String? getDevelopmentTeam(XcodeProject project) =>
    project.getBuildProperty('DEVELOPMENT_TEAM');
