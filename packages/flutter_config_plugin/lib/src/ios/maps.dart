library;

import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withGoogleMapsKey
// ---------------------------------------------------------------------------

/// Set the Google Maps iOS API key (GMSApiKey) in Info.plist.
ConfigPlugin withGoogleMapsKey(String apiKey) {
  return (config) => withMod(
        config,
        platform: 'ios',
        modName: 'infoPlist',
        action: (props) async {
          final plist = Map<String, dynamic>.from(
              (props.modResults as Map<String, dynamic>?) ?? {});
          plist['GMSApiKey'] = apiKey;
          return props.copyWith(modResults: plist);
        },
      );
}

// ---------------------------------------------------------------------------
// withMaps (combined)
// ---------------------------------------------------------------------------

/// Configure all Google Maps settings: API key in Info.plist.
ConfigPlugin withMaps({String? googleMapsApiKey}) {
  return (config) {
    if (googleMapsApiKey != null) {
      config = withGoogleMapsKey(googleMapsApiKey)(config);
    }
    return config;
  };
}

String? getGoogleMapsApiKey(Map<String, dynamic> plist) =>
    plist['GMSApiKey'] as String?;
