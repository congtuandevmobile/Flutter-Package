library;

import 'package:xml/xml.dart';
import '../../flutter_config_plugin.dart';
import '../android/android_plugins.dart';

/// Cấu hình Facebook SDK cho cả iOS và Android.
ConfigPlugin withFacebook({
  required String appId,
  required String clientToken,
  required String displayName,
  List<String> querySchemes = const ['facebook-stories', 'fbapi', 'fb-messenger-share-api'],
}) {
  return (config) {
    config = _withFacebookIos(config, appId, clientToken, displayName, querySchemes);
    config = _withFacebookAndroid(config, appId, clientToken);
    return config;
  };
}

FlutterConfig _withFacebookIos(
  FlutterConfig config,
  String appId,
  String clientToken,
  String displayName,
  List<String> querySchemes,
) {
  return withMod(
    config,
    platform: 'ios',
    modName: 'infoPlist',
    action: (props) async {
      final plist = Map<String, dynamic>.from((props.modResults as Map<String, dynamic>?) ?? {});

      plist['FacebookAppID'] = appId;
      plist['FacebookClientToken'] = clientToken;
      plist['FacebookDisplayName'] = displayName;

      // URL Types
      final urlTypes = List<Map<String, dynamic>>.from(
        (plist['CFBundleURLTypes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      );
      // Remove old fb scheme if exists
      urlTypes.removeWhere((type) {
        final schemes = (type['CFBundleURLSchemes'] as List?)?.cast<String>() ?? [];
        return schemes.any((s) => s.startsWith('fb'));
      });
      urlTypes.add({
        'CFBundleURLSchemes': ['fb\$appId']
      });
      plist['CFBundleURLTypes'] = urlTypes;

      // Queries Schemes
      final queries = List<String>.from((plist['LSApplicationQueriesSchemes'] as List?)?.cast<String>() ?? []);
      for (final scheme in querySchemes) {
        if (!queries.contains(scheme)) {
          queries.add(scheme);
        }
      }
      plist['LSApplicationQueriesSchemes'] = queries;

      return props.copyWith(modResults: plist);
    },
  );
}

FlutterConfig _withFacebookAndroid(
  FlutterConfig config,
  String appId,
  String clientToken,
) {
  config = withStringsXml(config, (doc) {
    final res = doc.rootElement;
    void addStr(String name, String value) {
      res.children.removeWhere((n) => n is XmlElement && n.name.local == 'string' && n.getAttribute('name') == name);
      res.children.add(XmlElement(XmlName('string'), [XmlAttribute(XmlName('name'), name)], [XmlText(value)]));
    }
    addStr('facebook_app_id', appId);
    addStr('facebook_client_token', clientToken);
    return doc;
  });

  config = withAndroidManifest(config, (doc) {
    final manifest = doc.rootElement;
    final app = manifest.findElements('application').firstOrNull;
    if (app != null) {
      void addMeta(String name, String value) {
        app.children.removeWhere((n) => n is XmlElement && n.name.local == 'meta-data' && n.getAttribute('android:name') == name);
        app.children.add(XmlElement(XmlName('meta-data'), [XmlAttribute(XmlName('android:name'), name), XmlAttribute(XmlName('android:value'), value)]));
      }
      addMeta('com.facebook.sdk.ApplicationId', '@string/facebook_app_id');
      addMeta('com.facebook.sdk.ClientToken', '@string/facebook_client_token');
    }

    // Queries cho Android 11+
    if (manifest.findElements('queries').isEmpty) {
      manifest.children.add(XmlElement(XmlName('queries')));
    }
    final queries = manifest.findElements('queries').first;
    
    // Check provider
    if (!queries.children.any((n) => n is XmlElement && n.name.local == 'provider' && n.getAttribute('android:authorities') == 'com.facebook.katana.provider.PlatformProvider')) {
      queries.children.add(XmlDocument.parse('<provider android:authorities="com.facebook.katana.provider.PlatformProvider" />').rootElement.copy());
      queries.children.add(XmlDocument.parse('<package android:name="com.facebook.katana" />').rootElement.copy());
      queries.children.add(XmlDocument.parse('<intent><action android:name="com.facebook.stories.ADD_TO_STORY" /></intent>').rootElement.copy());
    }

    return doc;
  });

  return config;
}
