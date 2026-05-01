library;

import 'package:xml/xml.dart';
import '../types.dart';
import '../with_mod.dart';

// ---------------------------------------------------------------------------
// withAndroidManifest
// ---------------------------------------------------------------------------

/// Modify AndroidManifest.xml.
///
/// ```dart
/// config = withAndroidManifest(config, (doc) {
///   final manifest = doc.rootElement;
///   manifest.children.add(XmlElement(XmlName('uses-permission'), [
///     XmlAttribute(XmlName('android:name'), 'android.permission.CAMERA'),
///   ]));
///   return doc;
/// });
/// ```
FlutterConfig withAndroidManifest(
  FlutterConfig config,
  XmlDocument Function(XmlDocument doc) action,
) {
  return withMod(
    config,
    platform: 'android',
    modName: 'manifest',
    action: (props) async {
      final doc = props.modResults as XmlDocument? ??
          XmlDocument.parse(
              '<manifest xmlns:android="http://schemas.android.com/apk/res/android"/>');
      return props.copyWith(modResults: action(doc));
    },
  );
}

/// Async variant of [withAndroidManifest].
FlutterConfig withAndroidManifestAsync(
  FlutterConfig config,
  Future<XmlDocument> Function(XmlDocument doc) action,
) {
  return withMod(
    config,
    platform: 'android',
    modName: 'manifest',
    action: (props) async {
      final doc = props.modResults as XmlDocument? ??
          XmlDocument.parse(
              '<manifest xmlns:android="http://schemas.android.com/apk/res/android"/>');
      return props.copyWith(modResults: await action(doc));
    },
  );
}

// ---------------------------------------------------------------------------
// withStringsXml
// ---------------------------------------------------------------------------

/// Modify res/values/strings.xml.
FlutterConfig withStringsXml(
  FlutterConfig config,
  XmlDocument Function(XmlDocument doc) action,
) {
  return withMod(
    config,
    platform: 'android',
    modName: 'strings',
    action: (props) async {
      final doc =
          props.modResults as XmlDocument? ?? XmlDocument.parse('<resources/>');
      return props.copyWith(modResults: action(doc));
    },
  );
}

// ---------------------------------------------------------------------------
// withAppBuildGradle
// ---------------------------------------------------------------------------

/// Modify app/build.gradle (raw text).
FlutterConfig withAppBuildGradle(
  FlutterConfig config,
  String Function(String contents) action,
) {
  return withMod(
    config,
    platform: 'android',
    modName: 'appBuildGradle',
    action: (props) async {
      final contents = (props.modResults as String?) ?? '';
      return props.copyWith(modResults: action(contents));
    },
  );
}

// ---------------------------------------------------------------------------
// Convenience helpers
// ---------------------------------------------------------------------------

/// Add a `<uses-permission>` to AndroidManifest.xml.
ConfigPlugin withAndroidPermission(String permissionName) {
  return (config) => withAndroidManifest(config, (doc) {
        final manifest = doc.rootElement;
        // Avoid duplicates.
        final already = manifest
            .findElements('uses-permission')
            .any((el) => el.getAttribute('android:name') == permissionName);
        if (!already) {
          manifest.children.insert(
            0,
            XmlElement(XmlName('uses-permission'), [
              XmlAttribute(XmlName('android:name'), permissionName),
            ]),
          );
        }
        return doc;
      });
}

/// Set the app label string in strings.xml.
ConfigPlugin withAndroidAppLabel(String label) {
  return (config) => withStringsXml(config, (doc) {
        final resources = doc.rootElement;
        // Remove existing app_name entry if present.
        resources.children.removeWhere((node) =>
            node is XmlElement &&
            node.name.local == 'string' &&
            node.getAttribute('name') == 'app_name');
        resources.children.add(
          XmlElement(XmlName('string'), [
            XmlAttribute(XmlName('name'), 'app_name'),
          ], [XmlText(label)]),
        );
        return doc;
      });
}

/// Add a minSdkVersion line to app/build.gradle if not present.
ConfigPlugin withMinSdkVersion(int version) {
  return (config) => withAppBuildGradle(config, (contents) {
        if (contents.contains('minSdkVersion')) return contents;
        return contents.replaceFirst(
          'defaultConfig {',
          'defaultConfig {\n        minSdkVersion $version',
        );
      });
}

/// Set an <application> meta-data.
ConfigPlugin withAndroidApplicationMetaData(String name, String value) {
  return (config) => withAndroidManifest(config, (doc) {
        final app = doc.rootElement.findElements('application').firstOrNull;
        if (app != null) {
          app.children.removeWhere((n) => n is XmlElement && n.name.local == 'meta-data' && n.getAttribute('android:name') == name);
          app.children.add(XmlElement(XmlName('meta-data'), [XmlAttribute(XmlName('android:name'), name), XmlAttribute(XmlName('android:value'), value)]));
        }
        return doc;
      });
}

/// Add a `<queries>` intent
ConfigPlugin withAndroidQueryIntent(String actionName, [String? mimeType]) {
  return (config) => withAndroidManifest(config, (doc) {
        final manifest = doc.rootElement;
        if (manifest.findElements('queries').isEmpty) {
          manifest.children.add(XmlDocument.parse('<queries></queries>').rootElement.copy());
        }
        final queries = manifest.findElements('queries').first;
        if (!queries.children.any((n) => n is XmlElement && n.name.local == 'intent' && n.children.any((c) => c is XmlElement && c.name.local == 'action' && c.getAttribute('android:name') == actionName))) {
          final mimeTag = mimeType != null ? '\n                <data android:mimeType="$mimeType"/>' : '';
          queries.children.add(XmlDocument.parse('''
            <intent>
                <action android:name="$actionName"/>$mimeTag
            </intent>
          ''').rootElement.copy());
        }
        return doc;
      });
}

/// Add `<uses-permission>` with maxSdkVersion
ConfigPlugin withAndroidPermissionMaxSdk(String permissionName, int maxSdk) {
  return (config) => withAndroidManifest(config, (doc) {
        final manifest = doc.rootElement;
        manifest.children.removeWhere((n) => n is XmlElement && n.name.local == 'uses-permission' && n.getAttribute('android:name') == permissionName);
        manifest.children.insert(0, XmlElement(XmlName('uses-permission'), [
          XmlAttribute(XmlName('android:name'), permissionName),
          XmlAttribute(XmlName('android:maxSdkVersion'), maxSdk.toString()),
        ]));
        return doc;
      });
}

/// Add an androidx.core.content.FileProvider
ConfigPlugin withAndroidFileProvider({
  required String authorities,
  String resourcePaths = '@xml/file_paths',
}) {
  return (config) => withAndroidManifest(config, (doc) {
        final app = doc.rootElement.findElements('application').firstOrNull;
        if (app != null) {
          if (!app.children.any((n) => n is XmlElement && n.name.local == 'provider' && n.getAttribute('android:name') == 'androidx.core.content.FileProvider')) {
            app.children.add(XmlDocument.parse('''
            <provider android:name="androidx.core.content.FileProvider" android:authorities="$authorities" android:exported="false" android:grantUriPermissions="true">
                <meta-data android:name="android.support.FILE_PROVIDER_PATHS" android:resource="$resourcePaths" />
            </provider>
            ''').rootElement.copy());
          }
        }
        return doc;
      });
}
