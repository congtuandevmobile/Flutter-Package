library;

import 'package:xml/xml.dart';
import '../../flutter_config_plugin.dart';
import '../android/android_plugins.dart';

/// Cấu hình Text-To-Speech (TTS) cho Android
ConfigPlugin withTts() {
  return (config) {
    config = withAndroidManifest(config, (doc) {
      final manifest = doc.rootElement;
      
      // Thêm thẻ <queries> nếu chưa có
      if (manifest.findElements('queries').isEmpty) {
        manifest.children.add(XmlElement(XmlName('queries')));
      }
      final queries = manifest.findElements('queries').first;
      
      // Thêm intent TTS_SERVICE
      if (!queries.children.any((n) => n is XmlElement && n.name.local == 'intent' && n.children.any((c) => c is XmlElement && c.name.local == 'action' && c.getAttribute('android:name') == 'android.intent.action.TTS_SERVICE'))) {
        queries.children.add(XmlDocument.parse('<intent><action android:name="android.intent.action.TTS_SERVICE" /></intent>').rootElement.copy());
      }

      return doc;
    });
    return config;
  };
}
