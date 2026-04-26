library;

import 'package:xml/xml.dart';
import '../../flutter_config_plugin.dart';
import '../android/android_plugins.dart';

/// Cấu hình Instagram (chủ yếu là cấu hình Android Queries để share Story)
ConfigPlugin withInstagram() {
  return (config) {
    config = _withInstagramAndroid(config);
    return config;
  };
}

FlutterConfig _withInstagramAndroid(FlutterConfig config) {
  return withAndroidManifest(config, (doc) {
    final manifest = doc.rootElement;
    
    // Thêm thẻ <queries> nếu chưa có
    if (manifest.findElements('queries').isEmpty) {
      manifest.children.add(XmlElement(XmlName('queries')));
    }
    final queries = manifest.findElements('queries').first;
    
    // Thêm package Instagram
    if (!queries.children.any((n) => n is XmlElement && n.name.local == 'package' && n.getAttribute('android:name') == 'com.instagram.android')) {
      queries.children.add(XmlDocument.parse('<package android:name="com.instagram.android" />').rootElement.copy());
      queries.children.add(XmlDocument.parse('<intent><action android:name="com.instagram.share.ADD_TO_STORY" /></intent>').rootElement.copy());
    }

    return doc;
  });
}
