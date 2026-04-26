library;

import '../types.dart';
import '../with_mod.dart';
import 'utils/xcodeproj.dart';

/// Provisioning profile configuration.
class ProvisioningProfileConfig {
  const ProvisioningProfileConfig({
    required this.profileSpecifier,
    required this.developmentTeam,
    this.codeSignIdentity = 'iPhone Distribution',
    this.buildName,
  });

  final String profileSpecifier;
  final String developmentTeam;
  final String codeSignIdentity;
  final String? buildName;
}

// ---------------------------------------------------------------------------
// withProvisioningProfile
// ---------------------------------------------------------------------------

/// Configure manual signing / provisioning profile in the Xcode project.
ConfigPlugin withProvisioningProfile(ProvisioningProfileConfig profile) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'xcodeproj',
        action: (props) async {
          final project = props.modResults as XcodeProject?;
          if (project == null) return props;
          setProvisioningProfileForPbxproj(project, profile);
          return props;
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void setProvisioningProfileForPbxproj(
    XcodeProject project, ProvisioningProfileConfig profile) {
  project.setBuildProperty(
      'PROVISIONING_PROFILE_SPECIFIER', profile.profileSpecifier,
      buildName: profile.buildName);
  project.setBuildProperty('DEVELOPMENT_TEAM', profile.developmentTeam,
      buildName: profile.buildName);
  project.setBuildProperty('CODE_SIGN_IDENTITY', profile.codeSignIdentity,
      buildName: profile.buildName);
  project.setBuildProperty('CODE_SIGN_STYLE', 'Manual',
      buildName: profile.buildName);
  project.setTargetAttribute('ProvisioningStyle', 'Manual');
  project.setTargetAttribute('DevelopmentTeam', profile.developmentTeam);
}
