library;

import 'package:xml/xml.dart';

import '../types.dart';
import '../android/android_plugins.dart';
import '../android/manifest_helpers.dart';
import '../ios/ios_plugins.dart';

// ─── PUBLIC ENTRY POINT ───────────────────────────────────────────────────────

/// Applies arbitrary native-file modifications declared as a plain Dart map
/// (typically parsed from the `generic:` section of `flutter_config.yaml`).
///
/// ══════════════════════════════════════════════════════════════════════════════
/// iOS — full schema
/// ══════════════════════════════════════════════════════════════════════════════
///
/// ```yaml
/// generic:
///   ios:
///     # ── Info.plist ─────────────────────────────────────────────────────────
///     # Bất kỳ key nào — string, bool, array, nested dict đều được
///     infoPlist:
///       TSLocationManagerLicense: ${MY_LICENSE}
///       CADisableMinimumFrameDurationOnPhone: true
///       NSAppTransportSecurity:
///         NSAllowsArbitraryLoads: false
///         NSExceptionDomains:
///           api.example.com:
///             NSExceptionAllowsInsecureHTTPLoads: true
///
///     # ── iOS Permissions (NSXxxUsageDescription keys trong Info.plist) ───────
///     # Shorthand — tương đương viết trong infoPlist: nhưng rõ ràng hơn
///     permissions:
///       NSCameraUsageDescription: '"App" cần dùng camera.'
///       NSLocationWhenInUseUsageDescription: '"App" cần vị trí.'
///       NSLocationAlwaysAndWhenInUseUsageDescription: '"App" cần vị trí nền.'
///       NSMicrophoneUsageDescription: '"App" cần dùng mic.'
///       NSPhotoLibraryUsageDescription: '"App" cần truy cập ảnh.'
///       NSPhotoLibraryAddUsageDescription: '"App" cần lưu ảnh.'
///       NSHealthShareUsageDescription: '"App" cần đọc health data.'
///       NSHealthUpdateUsageDescription: '"App" cần ghi health data.'
///       NSMotionUsageDescription: '"App" dùng motion để theo dõi.'
///       NSBluetoothAlwaysUsageDescription: '"App" cần kết nối Bluetooth.'
///       NSUserTrackingUsageDescription: '"App" dùng để cá nhân hoá.'
///       NSFaceIDUsageDescription: '"App" dùng Face ID.'
///       NSContactsUsageDescription: '"App" cần truy cập danh bạ.'
///
///     # ── UIBackgroundModes (merge vào array, không xoá cái cũ) ──────────────
///     backgroundModes:
///       - location
///       - fetch
///       - processing
///       - remote-notification
///       - audio
///       - voip
///       - bluetooth-central
///       - bluetooth-peripheral
///       - external-accessory
///       - nearby-interaction
///
///     # ── CFBundleURLTypes (URL Schemes) ─────────────────────────────────────
///     urlSchemes:
///       - role: Editor          # CFBundleTypeRole (Editor | Viewer)
///         name: google          # CFBundleName (optional)
///         schemes:
///           - com.googleusercontent.apps.${GID_CLIENT_ID}
///       - schemes:
///           - fb${FACEBOOK_APP_ID}
///
///     # ── LSApplicationQueriesSchemes ─────────────────────────────────────────
///     queriesSchemes:
///       - fbapi
///       - instagram
///       - fb-messenger-share-api
///
///     # ── .entitlements file (FILE KHÁC, không phải Info.plist) ───────────────
///     entitlements:
///       com.apple.developer.associated-domains:
///         - applinks:example.com
///         - webcredentials:example.com
///       aps-environment: production
///       com.apple.developer.healthkit: true
///       com.apple.security.application-groups:
///         - group.com.example.app
/// ```
///
/// ══════════════════════════════════════════════════════════════════════════════
/// Android — full schema
/// ══════════════════════════════════════════════════════════════════════════════
///
/// ```yaml
/// generic:
///   android:
///     # ── <uses-permission> ở ROOT <manifest> ────────────────────────────────
///     permissions:
///       - android.permission.INTERNET
///       - android.permission.CAMERA
///       - name: android.permission.READ_EXTERNAL_STORAGE
///         maxSdkVersion: 32           # thêm android:maxSdkVersion
///
///     # ── <uses-feature> ở ROOT <manifest> ───────────────────────────────────
///     # Nhiều thư viện (camera, NFC, BLE, GPS) cần khai báo phần cứng
///     features:
///       - name: android.hardware.camera
///         required: false             # false = optional (app chạy được không có)
///       - name: android.hardware.camera.autofocus
///         required: false
///       - name: android.hardware.nfc
///         required: false
///       - name: android.hardware.bluetooth_le
///         required: false
///       - name: android.hardware.location.gps
///         required: false
///
///     # ── res/values/strings.xml ──────────────────────────────────────────────
///     strings:
///       - name: facebook_app_id
///         value: ${FACEBOOK_APP_ID}
///       - name: facebook_client_token
///         value: ${FACEBOOK_CLIENT_TOKEN}
///
///     manifest:
///       # ── Attributes cho <application> element ────────────────────────────
///       # Các thuộc tính android:xxx trực tiếp trên thẻ <application>
///       applicationAttributes:
///         usesCleartextTraffic: true
///         networkSecurityConfig: '@xml/network_security_config'
///         largeHeap: true
///
///       application:
///         # ── <meta-data> INSIDE <application> ─────────────────────────────
///         meta-data:
///           - name: com.google.android.geo.API_KEY
///             value: ${GOOGLE_MAPS_API_KEY}
///           - name: com.facebook.sdk.ApplicationId
///             value: '@string/facebook_app_id'    # resource ref
///
///         # ── <service> INSIDE <application> ───────────────────────────────
///         services:
///           - name: com.transistorsoft.locationmanager.service.TrackingService
///             foregroundServiceType: location
///             exported: false
///             intentFilters:
///               - actions:
///                   - com.transistorsoft.locationmanager.service.TrackingService
///
///         # ── <receiver> INSIDE <application> ──────────────────────────────
///         receivers:
///           - name: com.transistorsoft.locationmanager.util.BootReceiver
///             exported: false
///             intentFilters:
///               - actions:
///                   - android.intent.action.BOOT_COMPLETED
///                   - android.intent.action.QUICKBOOT_POWERON
///                 # categories: (optional)
///                 #   - android.intent.category.DEFAULT
///
///         # ── <activity> INSIDE <application> (ngoài MainActivity) ─────────
///         activities:
///           - name: com.facebook.CustomTabActivity
///             exported: true
///             intentFilters:
///               - actions:
///                   - android.intent.action.VIEW
///                 categories:
///                   - android.intent.category.DEFAULT
///                   - android.intent.category.BROWSABLE
///                 # Một <data> element (scheme + host + path trên cùng thẻ):
///                 data:
///                   scheme: fb${FACEBOOK_APP_ID}
///                 # Nhiều <data> elements (deep link phức tạp):
///                 # dataList:
///                 #   - scheme: https
///                 #     host: example.com
///                 #     pathPrefix: /invite
///                 #   - scheme: myapp
///
///         # ── <provider> INSIDE <application> ──────────────────────────────
///         providers:
///           - name: androidx.core.content.FileProvider
///             authorities: ${APPLICATION_ID}.fileprovider
///             exported: false
///             grantUriPermissions: true
///             # Nhiều <meta-data> trong provider:
///             metaData:
///               - name: android.support.FILE_PROVIDER_PATHS
///                 resource: '@xml/file_paths'
///             # <grant-uri-permission>:
///             grantUriPermissionList:
///               - pathPattern: '.*'
///
///       # ── <queries> ở ROOT <manifest> ─────────────────────────────────────
///       queries:
///         - package: com.facebook.katana
///         - intent:
///             action: android.intent.action.VIEW
///             data:
///               scheme: https
///         - provider: com.facebook.katana.provider.PlatformProvider
/// ```
ConfigPlugin withGenericConfig(Map<String, dynamic> configMap) {
  return (config) {
    var c = config;
    c = _applyAndroid(c, configMap['android'] as Map<String, dynamic>?);
    c = _applyIos(c, configMap['ios'] as Map<String, dynamic>?);
    return c;
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// iOS
// ═══════════════════════════════════════════════════════════════════════════════

FlutterConfig _applyIos(FlutterConfig config, Map<String, dynamic>? ios) {
  if (ios == null) return config;
  var c = config;

  // 1. Direct Info.plist key-value pairs (bất kỳ key nào)
  final rawPlist = ios['infoPlist'];
  if (rawPlist != null) {
    final plistMap = Map<String, dynamic>.from(rawPlist as Map);
    c = withInfoPlist(c, (plist) => plist..addAll(plistMap));
  }

  // 2. iOS Permissions shorthand
  //    NSXxxUsageDescription keys → đặt vào Info.plist
  //    Đây CHỈ là shorthand; cũng có thể viết trực tiếp trong infoPlist:
  final rawPerms = ios['permissions'];
  if (rawPerms != null) {
    final permsMap = Map<String, dynamic>.from(rawPerms as Map);
    c = withInfoPlist(c, (plist) {
      permsMap.forEach((key, value) {
        if (value == null) {
          plist.remove(key);
        } else {
          plist[key] = value.toString();
        }
      });
      return plist;
    });
  }

  // 3. UIBackgroundModes — merge vào array, không xoá cái cũ
  final bgModes = ios['backgroundModes'] as List?;
  if (bgModes != null && bgModes.isNotEmpty) {
    c = withInfoPlist(c, (plist) {
      final existing = List<String>.from(
        (plist['UIBackgroundModes'] as List?)?.cast<String>() ?? [],
      );
      for (final mode in bgModes.cast<String>()) {
        if (!existing.contains(mode)) existing.add(mode);
      }
      plist['UIBackgroundModes'] = existing;
      return plist;
    });
  }

  // 4. CFBundleURLTypes (URL schemes)
  final urlSchemes = ios['urlSchemes'] as List?;
  if (urlSchemes != null && urlSchemes.isNotEmpty) {
    c = withInfoPlist(c, (plist) {
      final types = List<Map<String, dynamic>>.from(
        (plist['CFBundleURLTypes'] as List?)?.map((e) =>
            Map<String, dynamic>.from(e as Map)) ?? [],
      );
      for (final entry in urlSchemes.cast<Map>()) {
        final schemes = List<String>.from((entry['schemes'] as List?) ?? []);
        // Xoá entry cũ nếu có cùng scheme để tránh trùng
        types.removeWhere((t) {
          final existing = List<String>.from(
            (t['CFBundleURLSchemes'] as List?)?.cast<String>() ?? [],
          );
          return existing.any(schemes.contains);
        });
        final item = <String, dynamic>{'CFBundleURLSchemes': schemes};
        if (entry['role'] != null) item['CFBundleTypeRole'] = entry['role'];
        if (entry['name'] != null) item['CFBundleName'] = entry['name'];
        types.add(item);
      }
      plist['CFBundleURLTypes'] = types;
      return plist;
    });
  }

  // 5. LSApplicationQueriesSchemes
  final queriesSchemes = ios['queriesSchemes'] as List?;
  if (queriesSchemes != null && queriesSchemes.isNotEmpty) {
    c = withInfoPlist(c, (plist) {
      final existing = List<String>.from(
        (plist['LSApplicationQueriesSchemes'] as List?)?.cast<String>() ?? [],
      );
      for (final scheme in queriesSchemes.cast<String>()) {
        if (!existing.contains(scheme)) existing.add(scheme);
      }
      plist['LSApplicationQueriesSchemes'] = existing;
      return plist;
    });
  }

  // 6. Entitlements — FILE KHÁC (ios/Runner/Runner.entitlements), không phải Info.plist
  final rawEntitlements = ios['entitlements'];
  if (rawEntitlements != null) {
    final entMap = Map<String, dynamic>.from(rawEntitlements as Map);
    c = withEntitlements(c, (ent) => ent..addAll(entMap));
  }

  return c;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Android
// ═══════════════════════════════════════════════════════════════════════════════

FlutterConfig _applyAndroid(FlutterConfig config, Map<String, dynamic>? android) {
  if (android == null) return config;
  var c = config;

  // 1. <uses-permission> ở ROOT <manifest>
  final permissions = android['permissions'] as List?;
  if (permissions != null) {
    c = withAndroidManifest(c, (doc) {
      final manifest = doc.rootElement;
      for (final p in permissions) {
        if (p is String) {
          addPermission(doc, p);
        } else if (p is Map) {
          final name = p['name'] as String;
          final maxSdk = p['maxSdkVersion'];
          manifest.children.removeWhere((n) =>
              n is XmlElement &&
              n.name.local == 'uses-permission' &&
              n.getAttribute('android:name') == name);
          final el = XmlElement(XmlName('uses-permission'),
              [XmlAttribute(XmlName('android:name'), name)]);
          if (maxSdk != null) {
            el.setAttribute('android:maxSdkVersion', maxSdk.toString());
          }
          manifest.children.insert(0, el);
        }
      }
      return doc;
    });
  }

  // 2. <uses-feature> ở ROOT <manifest>
  //    Khai báo phần cứng yêu cầu/tuỳ chọn (camera, NFC, BLE, GPS...)
  final features = android['features'] as List?;
  if (features != null && features.isNotEmpty) {
    c = withAndroidManifest(c, (doc) {
      final manifest = doc.rootElement;
      for (final item in features.cast<Map>()) {
        final name = item['name'] as String;
        // Không thêm trùng
        if (manifest.children.any((n) =>
            n is XmlElement &&
            n.name.local == 'uses-feature' &&
            n.getAttribute('android:name') == name)) {
          continue;
        }
        final el = XmlElement(XmlName('uses-feature'),
            [XmlAttribute(XmlName('android:name'), name)]);
        final required = item['required'];
        if (required != null) {
          el.setAttribute('android:required', required.toString());
        }
        // Chèn sau uses-permission, trước application
        final appIdx = manifest.children.indexWhere(
            (n) => n is XmlElement && n.name.local == 'application');
        if (appIdx > 0) {
          manifest.children.insert(appIdx, el);
        } else {
          manifest.children.add(el);
        }
      }
      return doc;
    });
  }

  // 3. res/values/strings.xml
  final strings = android['strings'] as List?;
  if (strings != null && strings.isNotEmpty) {
    c = withStringsXml(c, (doc) {
      final res = doc.rootElement;
      for (final item in strings.cast<Map>()) {
        final name = item['name'] as String;
        final value = item['value']?.toString() ?? '';
        res.children.removeWhere((n) =>
            n is XmlElement &&
            n.name.local == 'string' &&
            n.getAttribute('name') == name);
        res.children.add(XmlElement(
          XmlName('string'),
          [XmlAttribute(XmlName('name'), name)],
          [XmlText(value)],
        ));
      }
      return doc;
    });
  }

  // 4. manifest.* section
  final manifestSection = android['manifest'] as Map<String, dynamic>?;
  if (manifestSection != null) {
    c = withAndroidManifest(c, (doc) {
      final manifest = doc.rootElement;
      final app = getMainApplicationOrThrow(doc);

      // 4a. Attributes trên <application> element
      //     Ví dụ: usesCleartextTraffic, networkSecurityConfig, largeHeap
      final appAttrs = manifestSection['applicationAttributes'] as Map?;
      if (appAttrs != null) {
        appAttrs.forEach((k, v) {
          app.setAttribute('android:$k', v.toString());
        });
      }

      // 4b. <meta-data> INSIDE <application>
      final metaDataList = manifestSection['application']?['meta-data'] as List?;
      if (metaDataList != null) {
        for (final item in metaDataList.cast<Map>()) {
          addMetaDataItemToMainApplication(
              app, item['name'] as String, item['value']?.toString() ?? '');
        }
      }

      // 4c. <service> INSIDE <application>
      final services = manifestSection['application']?['services'] as List?;
      if (services != null) {
        for (final item in services.cast<Map>()) {
          final name = item['name'] as String;
          if (_childExists(app, 'service', name)) continue;
          final el = XmlElement(XmlName('service'),
              [XmlAttribute(XmlName('android:name'), name)]);
          _applyAttrMap(el, item, skip: {'name', 'intentFilters'});
          _appendIntentFilters(el, item['intentFilters'] as List?);
          app.children.add(el);
        }
      }

      // 4d. <receiver> INSIDE <application>
      final receivers = manifestSection['application']?['receivers'] as List?;
      if (receivers != null) {
        for (final item in receivers.cast<Map>()) {
          final name = item['name'] as String;
          if (_childExists(app, 'receiver', name)) continue;
          final el = XmlElement(XmlName('receiver'),
              [XmlAttribute(XmlName('android:name'), name)]);
          _applyAttrMap(el, item, skip: {'name', 'intentFilters'});
          _appendIntentFilters(el, item['intentFilters'] as List?);
          app.children.add(el);
        }
      }

      // 4e. <activity> INSIDE <application> (ngoài MainActivity)
      final activities = manifestSection['application']?['activities'] as List?;
      if (activities != null) {
        for (final item in activities.cast<Map>()) {
          final name = item['name'] as String;
          if (_childExists(app, 'activity', name)) continue;
          final el = XmlElement(XmlName('activity'),
              [XmlAttribute(XmlName('android:name'), name)]);
          _applyAttrMap(el, item, skip: {'name', 'intentFilters'});
          _appendIntentFilters(el, item['intentFilters'] as List?);
          app.children.add(el);
        }
      }

      // 4f. <provider> INSIDE <application>
      final providers = manifestSection['application']?['providers'] as List?;
      if (providers != null) {
        for (final item in providers.cast<Map>()) {
          final name = item['name'] as String;
          if (_childExists(app, 'provider', name)) continue;
          final el = XmlElement(XmlName('provider'),
              [XmlAttribute(XmlName('android:name'), name)]);
          _applyAttrMap(el, item,
              skip: {'name', 'intentFilters', 'metaData', 'grantUriPermissionList'});

          // Multiple <meta-data> in provider
          final mdRaw = item['metaData'];
          if (mdRaw is List) {
            for (final md in mdRaw.cast<Map>()) {
              final mdEl = XmlElement(XmlName('meta-data'));
              md.forEach((k, v) => mdEl.setAttribute('android:$k', v.toString()));
              el.children.add(mdEl);
            }
          } else if (mdRaw is Map) {
            // Legacy single object format
            final mdEl = XmlElement(XmlName('meta-data'));
            mdRaw.forEach((k, v) => mdEl.setAttribute('android:$k', v.toString()));
            el.children.add(mdEl);
          }

          // <grant-uri-permission> list
          final grantList = item['grantUriPermissionList'] as List?;
          if (grantList != null) {
            for (final grant in grantList.cast<Map>()) {
              final gEl = XmlElement(XmlName('grant-uri-permission'));
              grant.forEach((k, v) => gEl.setAttribute('android:$k', v.toString()));
              el.children.add(gEl);
            }
          }

          app.children.add(el);
        }
      }

      // 4g. <queries> ở ROOT <manifest>
      final queries = manifestSection['queries'] as List?;
      if (queries != null && queries.isNotEmpty) {
        var queriesEl = manifest.findElements('queries').firstOrNull;
        if (queriesEl == null) {
          queriesEl = XmlElement(XmlName('queries'));
          manifest.children.add(queriesEl);
        }
        for (final item in queries.cast<Map>()) {
          if (item['package'] != null) {
            final pkgName = item['package'].toString();
            if (!queriesEl.children.any((n) =>
                n is XmlElement &&
                n.name.local == 'package' &&
                n.getAttribute('android:name') == pkgName)) {
              queriesEl.children.add(XmlElement(XmlName('package'),
                  [XmlAttribute(XmlName('android:name'), pkgName)]));
            }
          } else if (item['provider'] != null) {
            final auth = item['provider'].toString();
            if (!queriesEl.children.any((n) =>
                n is XmlElement &&
                n.name.local == 'provider' &&
                n.getAttribute('android:authorities') == auth)) {
              queriesEl.children.add(XmlElement(XmlName('provider'),
                  [XmlAttribute(XmlName('android:authorities'), auth)]));
            }
          } else if (item['intent'] != null) {
            final intentMap = item['intent'] as Map;
            final actionName = intentMap['action']?.toString();
            if (actionName != null &&
                !queriesEl.children.any((n) =>
                    n is XmlElement &&
                    n.name.local == 'intent' &&
                    n.children.any((c) =>
                        c is XmlElement &&
                        c.name.local == 'action' &&
                        c.getAttribute('android:name') == actionName))) {
              final intentEl = XmlElement(XmlName('intent'));
              intentEl.children.add(XmlElement(XmlName('action'),
                  [XmlAttribute(XmlName('android:name'), actionName)]));
              final data = intentMap['data'] as Map?;
              if (data != null) {
                final dataEl = XmlElement(XmlName('data'));
                data.forEach((k, v) =>
                    dataEl.setAttribute('android:$k', v.toString()));
                intentEl.children.add(dataEl);
              }
              queriesEl.children.add(intentEl);
            }
          }
        }
      }

      return doc;
    });
  }

  return c;
}

// ═══════════════════════════════════════════════════════════════════════════════
// XML helpers
// ═══════════════════════════════════════════════════════════════════════════════

/// True nếu [parent] đã có child [tag] với android:name=[name].
bool _childExists(XmlElement parent, String tag, String name) {
  return parent.children.any((n) =>
      n is XmlElement &&
      n.name.local == tag &&
      n.getAttribute('android:name') == name);
}

/// Copy map entries thành `android:<key>` attributes, bỏ qua [skip] keys.
void _applyAttrMap(XmlElement el, Map item, {Set<String> skip = const {}}) {
  item.forEach((k, v) {
    if (skip.contains(k as String)) return;
    el.setAttribute('android:$k', v.toString());
  });
}

/// Tạo và append các `<intent-filter>` từ list filter maps.
///
/// Mỗi filter map có thể chứa:
/// - `actions`    → `<action android:name="…"/>`
/// - `categories` → `<category android:name="…"/>`
/// - `data`       → `<data android:k="v" …/>` — một element, nhiều attributes
/// - `dataList`   → list of `<data>` elements (deep link phức tạp)
///
/// Ví dụ deep link với nhiều data:
/// ```yaml
/// intentFilters:
///   - actions: [android.intent.action.VIEW]
///     categories:
///       - android.intent.category.DEFAULT
///       - android.intent.category.BROWSABLE
///     dataList:
///       - scheme: https
///         host: example.com
///         pathPrefix: /invite
///       - scheme: myapp
/// ```
void _appendIntentFilters(XmlElement parent, List? filters) {
  if (filters == null || filters.isEmpty) return;
  for (final filter in filters.cast<Map>()) {
    final filterEl = XmlElement(XmlName('intent-filter'));
    // Optional label attribute on the intent-filter element itself
    // e.g. label: flutter_web_auth_2
    final label = filter['label'] as String?;
    if (label != null) filterEl.setAttribute('android:label', label);

    for (final action
        in (filter['actions'] as List?)?.cast<String>() ?? []) {
      filterEl.children.add(XmlElement(XmlName('action'),
          [XmlAttribute(XmlName('android:name'), action)]));
    }
    for (final cat
        in (filter['categories'] as List?)?.cast<String>() ?? []) {
      filterEl.children.add(XmlElement(XmlName('category'),
          [XmlAttribute(XmlName('android:name'), cat)]));
    }

    // Một <data> element với nhiều attributes (scheme, host, path trên cùng thẻ)
    final data = filter['data'] as Map?;
    if (data != null) {
      final dataEl = XmlElement(XmlName('data'));
      data.forEach((k, v) => dataEl.setAttribute('android:$k', v.toString()));
      filterEl.children.add(dataEl);
    }

    // Nhiều <data> elements (khi cần khai báo nhiều pattern riêng biệt)
    final dataList = filter['dataList'] as List?;
    if (dataList != null) {
      for (final d in dataList.cast<Map>()) {
        final dataEl = XmlElement(XmlName('data'));
        d.forEach((k, v) => dataEl.setAttribute('android:$k', v.toString()));
        filterEl.children.add(dataEl);
      }
    }

    parent.children.add(filterEl);
  }
}
