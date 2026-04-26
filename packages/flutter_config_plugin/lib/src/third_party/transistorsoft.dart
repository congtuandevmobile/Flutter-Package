library;

import 'package:xml/xml.dart';
import '../../flutter_config_plugin.dart';
import '../android/android_plugins.dart';

/// Cấu hình Background Geolocation (transistorsoft) cho iOS và Android.
ConfigPlugin withTransistorsoftLocation({
  required String licenseKey,
}) {
  return (config) {
    config = _withIos(config, licenseKey);
    config = _withAndroid(config, licenseKey);
    return config;
  };
}

FlutterConfig _withIos(FlutterConfig config, String licenseKey) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'infoPlist',
    action: (props) async {
      final plist = Map<String, dynamic>.from((props.modResults as Map<String, dynamic>?) ?? {});
      
      plist['TSLocationManagerLicense'] = licenseKey;
      
      // Ensure Background Modes
      final bgModes = List<String>.from((plist['UIBackgroundModes'] as List?)?.cast<String>() ?? []);
      for (final mode in ['location', 'fetch', 'processing']) {
        if (!bgModes.contains(mode)) {
          bgModes.add(mode);
        }
      }
      plist['UIBackgroundModes'] = bgModes;

      return props.copyWith(modResults: plist);
    },
  );
}

FlutterConfig _withAndroid(FlutterConfig config, String licenseKey) {
  return withAndroidManifest(config, (doc) {
    final manifest = doc.rootElement;
    final app = manifest.findElements('application').firstOrNull;
    if (app != null) {
      // License key meta-data
      app.children.removeWhere((n) => n is XmlElement && n.name.local == 'meta-data' && n.getAttribute('android:name') == 'com.transistorsoft.locationmanager.license');
      app.children.add(XmlElement(XmlName('meta-data'), [
        XmlAttribute(XmlName('android:name'), 'com.transistorsoft.locationmanager.license'),
        XmlAttribute(XmlName('android:value'), licenseKey)
      ]));

      // Thêm services
      if (!app.children.any((n) => n is XmlElement && n.name.local == 'service' && n.getAttribute('android:name') == 'com.transistorsoft.locationmanager.service.TrackingService')) {
        app.children.add(XmlDocument.parse('<service android:name="com.transistorsoft.locationmanager.service.TrackingService" android:foregroundServiceType="location" />').rootElement.copy());
        app.children.add(XmlDocument.parse('<service android:name="com.transistorsoft.locationmanager.service.LocationRequestService" android:foregroundServiceType="location" />').rootElement.copy());
        app.children.add(XmlDocument.parse('<service android:name="com.transistorsoft.locationmanager.service.ActivityRecognitionService" android:foregroundServiceType="dataSync" android:exported="false" />').rootElement.copy());
        app.children.add(XmlDocument.parse('''
        <receiver android:name="com.transistorsoft.locationmanager.util.BootReceiver" android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
        ''').rootElement.copy());
      }
    }
    return doc;
  });
}
