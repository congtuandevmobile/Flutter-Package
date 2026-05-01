library;

import 'dart:io';
import 'package:path/path.dart' as p;

import '../types.dart';
import '../with_mod.dart';
import '../utils/plist_utils.dart';

/// Privacy manifest configuration (PrivacyInfo.xcprivacy).
class PrivacyInfoConfig {
  const PrivacyInfoConfig({
    this.privacyTracking = false,
    this.privacyTrackingDomains = const [],
    this.privacyAccessedApiTypes = const [],
    this.privacyCollectedDataTypes = const [],
  });

  /// Whether the app uses data for tracking.
  final bool privacyTracking;

  /// Tracking domains list.
  final List<String> privacyTrackingDomains;

  /// NSPrivacyAccessedAPITypes entries.
  final List<Map<String, dynamic>> privacyAccessedApiTypes;

  /// NSPrivacyCollectedDataTypes entries.
  final List<Map<String, dynamic>> privacyCollectedDataTypes;
}

// ---------------------------------------------------------------------------
// withPrivacyInfo
// ---------------------------------------------------------------------------

/// Create or update the PrivacyInfo.xcprivacy manifest.
ConfigPlugin withPrivacyInfo(PrivacyInfoConfig privacyInfo) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'dangerous',
        action: (props) async {
          if (props.modRequest.introspect) return props;
          await setPrivacyInfo(
              props.modRequest.platformProjectRoot, privacyInfo);
          return props;
        },
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> setPrivacyInfo(
    String iosRoot, PrivacyInfoConfig privacyInfo) async {
  final filePath =
      p.join(iosRoot, 'Runner', 'PrivacyInfo.xcprivacy');

  Map<String, dynamic> existing = {};
  final file = File(filePath);
  if (file.existsSync()) {
    try {
      existing = parsePlist(await file.readAsString());
    } catch (_) {}
  }

  existing['NSPrivacyTracking'] = privacyInfo.privacyTracking;

  if (privacyInfo.privacyTrackingDomains.isNotEmpty) {
    final domains = List<String>.from(
        existing['NSPrivacyTrackingDomains'] as List? ?? []);
    for (final d in privacyInfo.privacyTrackingDomains) {
      if (!domains.contains(d)) domains.add(d);
    }
    existing['NSPrivacyTrackingDomains'] = domains;
  }

  if (privacyInfo.privacyAccessedApiTypes.isNotEmpty) {
    existing['NSPrivacyAccessedAPITypes'] = privacyInfo.privacyAccessedApiTypes;
  }

  if (privacyInfo.privacyCollectedDataTypes.isNotEmpty) {
    existing['NSPrivacyCollectedDataTypes'] =
        privacyInfo.privacyCollectedDataTypes;
  }

  await file.writeAsString(buildPlist(existing));
}
