library;

import 'package:xml/xml.dart';
import '../../flutter_config_plugin.dart';
import '../android/android_plugins.dart';

/// Cấu hình Activity Callback cho Web Auth (ví dụ: flutter_web_auth_2)
ConfigPlugin withWebAuthCallback({
  required List<String> schemes,
  String intentLabel = 'flutter_web_auth_2',
  String activityName = 'com.linusu.flutter_web_auth_2.CallbackActivity',
}) {
  return (config) {
    return withAndroidManifest(config, (doc) {
      final manifest = doc.rootElement;
      final app = manifest.findElements('application').firstOrNull;
      if (app != null) {
        if (!app.children.any((n) => n is XmlElement && n.name.local == 'activity' && n.getAttribute('android:name') == activityName)) {
          final dataTags = schemes.map((s) => '<data android:scheme="$s" />').join('\n                  ');
          final webAuthActivity = XmlDocument.parse('''
          <activity android:name="$activityName" android:exported="true">
              <intent-filter android:label="$intentLabel">
                  <action android:name="android.intent.action.VIEW" />
                  <category android:name="android.intent.category.DEFAULT" />
                  <category android:name="android.intent.category.BROWSABLE" />
                  $dataTags
              </intent-filter>
          </activity>
          ''').rootElement;
          app.children.add(webAuthActivity.copy());
        }
      }
      return doc;
    });
  };
}
