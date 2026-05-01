library;

import '../types.dart';
import '../with_mod.dart';
import 'utils/xcodeproj.dart';

// ---------------------------------------------------------------------------
// withBitcode
// ---------------------------------------------------------------------------

/// Enable or disable bitcode (ENABLE_BITCODE) in the Xcode project.
ConfigPlugin withBitcode({required bool enabled, String? buildName}) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'xcodeproj',
        action: (props) async {
          final project = props.modResults as XcodeProject?;
          if (project == null) return props;
          setBitcode(project, enabled: enabled, buildName: buildName);
          return props;
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void setBitcode(XcodeProject project,
    {required bool enabled, String? buildName}) {
  project.setBuildProperty(
    'ENABLE_BITCODE',
    enabled ? 'YES' : 'NO',
    buildName: buildName,
  );
}

bool? getBitcode(XcodeProject project, {String? buildName}) {
  final value = project.getBuildProperty('ENABLE_BITCODE', buildName: buildName);
  if (value == null) return null;
  return value.toUpperCase() == 'YES';
}
