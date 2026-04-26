library;

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

const _metaApiKey = 'com.google.android.geo.API_KEY';
const _libHttp = 'org.apache.http.legacy';

// ---------------------------------------------------------------------------
// withGoogleMapsApiKey
// ---------------------------------------------------------------------------

/// Set the Google Maps Android API key in AndroidManifest.xml.
ConfigPlugin withGoogleMapsApiKey(String apiKey) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          final app = getMainApplicationOrThrow(doc);
          addMetaDataItemToMainApplication(app, _metaApiKey, apiKey);
          addUsesLibraryItemToMainApplication(app,
              name: _libHttp, required: false);
          return props.copyWith(modResults: doc);
        },
      );
}

/// Remove the Google Maps API key from AndroidManifest.xml.
ConfigPlugin withoutGoogleMapsApiKey() {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          final app = getMainApplicationOrThrow(doc);
          removeMetaDataItemFromMainApplication(app, _metaApiKey);
          removeUsesLibraryItemFromMainApplication(app, _libHttp);
          return props.copyWith(modResults: doc);
        },
      );
}

String? getGoogleMapsApiKey(dynamic manifestDoc) {
  if (manifestDoc == null) return null;
  final app = getMainApplication(manifestDoc);
  return app == null ? null : getMetaDataItem(app, _metaApiKey)?.getAttribute('android:value');
}
