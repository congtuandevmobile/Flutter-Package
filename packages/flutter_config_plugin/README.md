# flutter_config_plugin

A composable pipeline for modifying iOS and Android native project files, inspired by [`@expo/config-plugins`](https://github.com/expo/expo/tree/main/packages/%40expo/config-plugins).

Configure `Info.plist`, `AndroidManifest.xml`, entitlements, `strings.xml`, and Xcode project settings — all from a single `flutter_config.yaml` file. Environment variables are resolved from `.env` in development and from CI variables in production, with no code changes required.

---

## Table of Contents

- [How it works](#how-it-works)
- [Quick start](#quick-start)
- [flutter_config.yaml reference](#flutter_configyaml-reference)
  - [app](#app)
  - [generic › iOS](#generic--ios)
  - [generic › Android](#generic--android)
- [Environment variables](#environment-variables)
- [CLI reference](#cli-reference)
- [Dart API](#dart-api)
- [CI/CD integration](#cicd-integration)
- [Git workflow](#git-workflow)
- [Extending with custom plugins](#extending-with-custom-plugins)

---

## How it works

```
flutter_config.yaml  +  .env / CI variables
         │
         ▼
  dart run flutter_config_plugin:flutter_config
         │
         ├─► ios/Runner/Info.plist
         ├─► ios/Runner/Runner.entitlements
         ├─► android/app/src/main/AndroidManifest.xml
         └─► android/app/src/main/res/values/strings.xml
```

The tool uses a **mod pipeline** pattern:

1. `withXxx()` functions **register** modifications onto a `FlutterConfig` object (pure functions — no I/O at this stage).
2. `compileModsAsync()` **executes** the chain: base mods read the native file, pass it through every registered modifier in order, then write the result back.

Each mod is **idempotent** — running the tool multiple times produces the same output.

---

## Quick start

### 1. Add the dependency

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_config_plugin: ^0.0.1
```

```bash
flutter pub get
```

### 2. Create `flutter_config.yaml` in your Flutter app directory

```yaml
app:
  name: ${APP_NAME}
  bundleIdentifier: ${BUNDLE_ID}
  applicationId: ${APPLICATION_ID}
  version: "1.0.0"

generic:
  ios:
    infoPlist:
      API_URL: ${API_URL}
    permissions:
      NSCameraUsageDescription: '"MyApp" needs camera access.'

  android:
    permissions:
      - android.permission.INTERNET
      - android.permission.CAMERA
```

### 3. Create `.env` in the same directory as `flutter_config.yaml`

```bash
# .env  (never commit this file — add it to .gitignore)
APP_NAME=MyApp Dev
BUNDLE_ID=com.example.myapp
APPLICATION_ID=com.example.myapp
API_URL=https://api.example.com
```

Keep a `.env.example` with placeholder values committed to git so teammates know which variables are required:

```bash
cp .env.example .env   # then fill in real values
```

### 4. Run the tool

```bash
dart run flutter_config_plugin:flutter_config path/to/your/app
```

---

## flutter_config.yaml reference

### `app`

Top-level app metadata. All fields support `${VAR}` substitution.

```yaml
app:
  name: ${APP_NAME}               # App display name
  bundleIdentifier: ${BUNDLE_ID}  # iOS bundle identifier
  applicationId: ${APPLICATION_ID} # Android application ID
  version: "1.0.0"               # Semver string
```

---

### `generic › iOS`

All modifications under `generic.ios` target **iOS native files**.

#### `infoPlist`

Writes arbitrary key-value pairs to `Info.plist`. Supports strings, booleans, numbers, arrays, and nested dicts.

```yaml
generic:
  ios:
    infoPlist:
      # String
      API_URL: ${API_URL}
      GOOGLE_MAPS_API_KEY: ${GOOGLE_MAPS_API_KEY}
      GIDClientID: ${GOOGLE_CLIENT_ID}

      # Boolean (no quotes)
      CADisableMinimumFrameDurationOnPhone: true

      # Array
      BGTaskSchedulerPermittedIdentifiers:
        - com.example.healthkit.sync

      # Nested dict (e.g. App Transport Security)
      NSAppTransportSecurity:
        NSAllowsArbitraryLoads: false
        NSExceptionDomains:
          api.example.com:
            NSExceptionAllowsInsecureHTTPLoads: true
            NSThirdPartyExceptionRequiresForwardSecrecy: false

      # SDK-specific keys
      FacebookAppID: ${FACEBOOK_APP_ID}
      FacebookClientToken: ${FACEBOOK_CLIENT_TOKEN}
      FacebookDisplayName: ${APP_NAME}
      TSLocationManagerLicense: ${BG_GEOLOCATION_LICENSE}
```

#### `permissions`

Shorthand for `NSXxxUsageDescription` keys. Functionally equivalent to writing them in `infoPlist`, but grouped for clarity.

```yaml
generic:
  ios:
    permissions:
      NSCameraUsageDescription: '"MyApp" needs camera access.'
      NSMicrophoneUsageDescription: '"MyApp" needs microphone access.'
      NSPhotoLibraryUsageDescription: 'MyApp needs photo library access.'
      NSPhotoLibraryAddUsageDescription: '"MyApp" needs to save photos.'
      NSLocationWhenInUseUsageDescription: '"MyApp" needs location while in use.'
      NSLocationAlwaysAndWhenInUseUsageDescription: '"MyApp" needs background location.'
      NSMotionUsageDescription: 'MyApp uses motion data for activity tracking.'
      NSHealthShareUsageDescription: '"MyApp" needs to read health data.'
      NSHealthUpdateUsageDescription: '"MyApp" needs to write health data.'
      NSBluetoothAlwaysUsageDescription: '"MyApp" needs Bluetooth access.'
      NSUserTrackingUsageDescription: '"MyApp" uses tracking for personalization.'
      NSFaceIDUsageDescription: '"MyApp" uses Face ID for authentication.'
      NSContactsUsageDescription: '"MyApp" needs access to your contacts.'
```

#### `backgroundModes`

Merges values into the `UIBackgroundModes` array in `Info.plist`. Existing values are preserved; duplicates are skipped.

```yaml
generic:
  ios:
    backgroundModes:
      - location           # flutter_background_geolocation
      - fetch
      - processing         # BGTaskScheduler
      - remote-notification
      - audio
      - voip
      - bluetooth-central
      - bluetooth-peripheral
      - external-accessory
      - nearby-interaction
```

#### `urlSchemes`

Writes `CFBundleURLTypes` entries for URL scheme registration (Google Sign-In, Facebook, deep links).

```yaml
generic:
  ios:
    urlSchemes:
      # Google Sign-In (reversed client ID)
      - role: Editor          # CFBundleTypeRole: Editor | Viewer
        name: google          # CFBundleName (optional)
        schemes:
          - ${GOOGLE_REVERSED_CLIENT_ID}

      # Facebook — prefix "fb" + numeric app ID
      - schemes:
          - fb${FACEBOOK_APP_ID}

      # Deep link callback (multiple schemes in one entry)
      - role: Editor
        name: app_callback
        schemes:
          - ${URL_SCHEME}
          - ${URL_SCHEME_UAT}
```

#### `queriesSchemes`

Merges values into `LSApplicationQueriesSchemes` (what apps your app can query with `canOpenURL`).

```yaml
generic:
  ios:
    queriesSchemes:
      - fbapi
      - fb-messenger-share-api
      - facebook-stories
      - instagram-stories
      - App-prefs
```

#### `entitlements`

Writes to `ios/Runner/Runner.entitlements` — a **separate file** from `Info.plist`.

```yaml
generic:
  ios:
    entitlements:
      # Associated domains (Universal Links, Sign in with Apple)
      com.apple.developer.associated-domains:
        - applinks:example.com
        - webcredentials:example.com

      # Push notifications environment
      aps-environment: production     # or: development

      # HealthKit
      com.apple.developer.healthkit: true
      com.apple.developer.healthkit.access:
        - health-records

      # App Groups (shared container between app and extensions)
      com.apple.security.application-groups:
        - group.com.example.myapp

      # iCloud (CloudKit)
      com.apple.developer.icloud-services:
        - CloudKit
      com.apple.developer.icloud-container-identifiers:
        - iCloud.com.example.myapp
```

---

### `generic › Android`

All modifications under `generic.android` target **Android native files**.

#### `permissions`

Adds `<uses-permission>` elements to the root `<manifest>`. Supports optional `maxSdkVersion`.

```yaml
generic:
  android:
    permissions:
      # Simple string form
      - android.permission.INTERNET
      - android.permission.ACCESS_NETWORK_STATE
      - android.permission.CAMERA
      - android.permission.READ_MEDIA_IMAGES
      - android.permission.READ_MEDIA_VIDEO
      - android.permission.ACCESS_FINE_LOCATION
      - android.permission.ACCESS_COARSE_LOCATION
      - android.permission.ACCESS_BACKGROUND_LOCATION
      - android.permission.FOREGROUND_SERVICE
      - android.permission.FOREGROUND_SERVICE_LOCATION
      - android.permission.FOREGROUND_SERVICE_DATA_SYNC
      - android.permission.RECEIVE_BOOT_COMPLETED
      - android.permission.POST_NOTIFICATIONS
      - android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
      - android.permission.ACTIVITY_RECOGNITION
      - com.google.android.gms.permission.ACTIVITY_RECOGNITION

      # With maxSdkVersion attribute
      - name: android.permission.READ_EXTERNAL_STORAGE
        maxSdkVersion: 32
      - name: android.permission.WRITE_EXTERNAL_STORAGE
        maxSdkVersion: 32
```

#### `features`

Adds `<uses-feature>` elements to the root `<manifest>`.

```yaml
generic:
  android:
    features:
      - name: android.hardware.camera
        required: false    # false = optional, app can run without it
      - name: android.hardware.camera.autofocus
        required: false
      - name: android.hardware.nfc
        required: false
      - name: android.hardware.bluetooth_le
        required: false
      - name: android.hardware.location.gps
        required: false
```

#### `strings`

Writes `<string>` elements to `res/values/strings.xml`. Used when SDKs require resource references (`@string/xxx`) instead of raw values in the manifest.

```yaml
generic:
  android:
    strings:
      - name: facebook_app_id
        value: ${FACEBOOK_APP_ID}
      - name: facebook_client_token
        value: ${FACEBOOK_CLIENT_TOKEN}
```

#### `manifest.applicationAttributes`

Sets attributes directly on the `<application>` element.

```yaml
generic:
  android:
    manifest:
      applicationAttributes:
        usesCleartextTraffic: "true"
        networkSecurityConfig: '@xml/network_security_config'
        largeHeap: "true"
```

#### `manifest.application.meta-data`

Adds `<meta-data>` elements inside `<application>`.

```yaml
generic:
  android:
    manifest:
      application:
        meta-data:
          - name: flutterEmbedding
            value: "2"
          - name: com.google.android.geo.API_KEY
            value: ${GOOGLE_MAPS_API_KEY}
          - name: com.google.android.gms.maps.RENDERER
            value: LATEST
          # Reference a strings.xml value
          - name: com.facebook.sdk.ApplicationId
            value: '@string/facebook_app_id'
          - name: com.facebook.sdk.ClientToken
            value: '@string/facebook_client_token'
          - name: com.transistorsoft.locationmanager.license
            value: ${BG_GEOLOCATION_LICENSE}
```

#### `manifest.application.services`

Adds `<service>` elements inside `<application>`.

```yaml
generic:
  android:
    manifest:
      application:
        services:
          - name: com.transistorsoft.locationmanager.service.TrackingService
            foregroundServiceType: location
          - name: com.transistorsoft.locationmanager.service.LocationRequestService
            foregroundServiceType: location
          - name: com.transistorsoft.locationmanager.service.ActivityRecognitionService
            foregroundServiceType: dataSync
            exported: "false"
            # Optional intent filters on a service
            intentFilters:
              - actions:
                  - com.transistorsoft.locationmanager.service.ActivityRecognitionService
```

#### `manifest.application.receivers`

Adds `<receiver>` elements inside `<application>`.

```yaml
generic:
  android:
    manifest:
      application:
        receivers:
          - name: com.transistorsoft.locationmanager.util.BootReceiver
            exported: "false"
            intentFilters:
              - actions:
                  - android.intent.action.BOOT_COMPLETED
                  - android.intent.action.QUICKBOOT_POWERON
                  - com.htc.intent.action.QUICKBOOT_POWERON
                categories:           # optional
                  - android.intent.category.DEFAULT
```

#### `manifest.application.activities`

Adds `<activity>` elements inside `<application>`. Supports `data` (single element) and `dataList` (multiple elements) for complex deep links.

```yaml
generic:
  android:
    manifest:
      application:
        activities:
          # OAuth / deep link callback (flutter_web_auth_2)
          - name: com.linusu.flutter_web_auth_2.CallbackActivity
            exported: "true"
            intentFilters:
              - label: flutter_web_auth_2    # android:label on <intent-filter>
                actions:
                  - android.intent.action.VIEW
                categories:
                  - android.intent.category.DEFAULT
                  - android.intent.category.BROWSABLE
                # Multiple <data> elements (one per scheme)
                dataList:
                  - scheme: ${URL_SCHEME}
                  - scheme: ${URL_SCHEME_UAT}

          # Single <data> with scheme + host + path on the same element
          - name: com.example.DeepLinkActivity
            exported: "true"
            intentFilters:
              - actions:
                  - android.intent.action.VIEW
                categories:
                  - android.intent.category.DEFAULT
                  - android.intent.category.BROWSABLE
                data:
                  scheme: https
                  host: example.com
                  pathPrefix: /invite
```

#### `manifest.application.providers`

Adds `<provider>` elements inside `<application>`. Supports multiple `metaData` entries and `grantUriPermissionList`.

```yaml
generic:
  android:
    manifest:
      application:
        providers:
          - name: androidx.core.content.FileProvider
            authorities: ${APPLICATION_ID}.fileprovider
            exported: "false"
            grantUriPermissions: "true"
            metaData:
              - name: android.support.FILE_PROVIDER_PATHS
                resource: '@xml/file_paths'
            # Optional <grant-uri-permission> elements
            grantUriPermissionList:
              - pathPattern: '.*'
```

#### `manifest.queries`

Adds entries to the `<queries>` block (required to query other apps on Android 11+).

```yaml
generic:
  android:
    manifest:
      queries:
        # Query by package name
        - package: com.facebook.katana
        - package: com.instagram.android

        # Query by content provider authority
        - provider: com.facebook.katana.provider.PlatformProvider

        # Query by intent action (optionally with a data filter)
        - intent:
            action: android.intent.action.PROCESS_TEXT
            data:
              mimeType: text/plain
        - intent:
            action: com.facebook.stories.ADD_TO_STORY
        - intent:
            action: android.intent.action.TTS_SERVICE
```

---

## Environment variables

Any value in `flutter_config.yaml` can reference an environment variable with `${VAR_NAME}` syntax. References can appear anywhere in a string:

```yaml
# Standalone
GOOGLE_MAPS_API_KEY: ${GOOGLE_MAPS_API_KEY}

# Embedded (prefix is preserved)
- fb${FACEBOOK_APP_ID}                    # → fb123456789
- ${GOOGLE_REVERSED_CLIENT_ID}            # → com.googleusercontent.apps.xxx
```

### Resolution order (highest → lowest)

| Priority | Source | When |
|---|---|---|
| 1 | `Platform.environment` | CI runner, shell exports |
| 2 | `.env` file in project root | Local development |
| 3 | Empty string | Variable not found anywhere |

### `.env` format

```bash
# .env — never commit this file
APP_NAME=MyApp
BUNDLE_ID=com.example.myapp
APPLICATION_ID=com.example.myapp
URL_SCHEME=myapp
URL_SCHEME_UAT=myapp-uat
API_URL=https://api.example.com
GOOGLE_MAPS_API_KEY=AIzaSy...
GOOGLE_CLIENT_ID=123456.apps.googleusercontent.com
GOOGLE_REVERSED_CLIENT_ID=com.googleusercontent.apps.123456
FACEBOOK_APP_ID=123456789
FACEBOOK_CLIENT_TOKEN=abc123
BG_GEOLOCATION_LICENSE=eyJhbGci...
```

---

## CLI reference

```
dart run flutter_config_plugin:flutter_config [project_root] [options]
```

| Argument / Option | Default | Description |
|---|---|---|
| `project_root` | Current directory | Path to the Flutter project (contains `flutter_config.yaml`) |
| `--dry-run` | `false` | Resolve and print config without writing any files |
| `--check` | `false` | Print which env vars are required/missing and exit |
| `--no-fail-env` | `false` | Continue even if required env vars are missing |
| `--platforms ios,android` | `ios,android` | Restrict which platforms to process |

```bash
# Apply to both platforms (default)
dart run flutter_config_plugin:flutter_config path/to/app

# Preview without writing files
dart run flutter_config_plugin:flutter_config path/to/app --dry-run

# Check env var requirements
dart run flutter_config_plugin:flutter_config path/to/app --check

# Android only
dart run flutter_config_plugin:flutter_config path/to/app --platforms android
```

---

## Dart API

### Core types

```dart
// A plugin: takes a config, returns a modified config (pure)
typedef ConfigPlugin = FlutterConfig Function(FlutterConfig config);

// Root config object passed through every plugin and mod
class FlutterConfig {
  final String name;
  final String? bundleIdentifier;
  final String? applicationId;
  final String version;
  final Map<String, Map<String, ConfigMod>> mods;
}
```

### Composing plugins

```dart
import 'package:flutter_config_plugin/flutter_config_plugin.dart';

var config = const FlutterConfig(
  name: 'MyApp',
  bundleIdentifier: 'com.example.myapp',
  applicationId: 'com.example.myapp',
);

config = withPlugins(config, [
  withDisplayName('My Awesome App'),
  withBundleIdentifier('com.example.myapp'),
  withDeploymentTarget('14.0'),
  withIosPermission(key: IosPermissions.camera, description: 'Scan QR codes'),
  withAssociatedDomains(['applinks:example.com']),
  withAndroidPermission(AndroidPermissions.camera),
  withAndroidName('My Awesome App'),
]);

await compileModsAsync(
  config,
  CompileModsOptions(projectRoot: '/path/to/project'),
);
```

### Writing a custom mod

```dart
// Mod that sets a raw Info.plist key
ConfigPlugin withMyLicenseKey(String key) {
  return (config) => withInfoPlist(config, (plist) {
    plist['MySDKLicense'] = key;
    return plist;
  });
}

// Mod that adds a <receiver> to AndroidManifest.xml
ConfigPlugin withMyReceiver() {
  return (config) => withAndroidManifest(config, (doc) {
    final app = getMainApplicationOrThrow(doc);
    app.children.add(XmlElement(XmlName('receiver'), [
      XmlAttribute(XmlName('android:name'), 'com.example.MyReceiver'),
      XmlAttribute(XmlName('android:exported'), 'false'),
    ]));
    return doc;
  });
}
```

### Run-once guard

Prevents a plugin from being applied twice if multiple packages depend on it:

```dart
ConfigPlugin myPlugin() => createRunOncePlugin(
  (config) => withPlugins(config, [
    withMyLicenseKey('abc'),
    withMyReceiver(),
  ]),
  name: 'my-sdk',
  version: '1.0.0',
);
```

### Apply a YAML config at runtime

```dart
loadDotEnv('/path/to/app');
final rawConfig = parseYamlToMap(File('flutter_config.yaml').readAsStringSync());

var config = FlutterConfig(
  name: rawConfig['app']['name'] as String,
  bundleIdentifier: rawConfig['app']['bundleIdentifier'] as String?,
  applicationId: rawConfig['app']['applicationId'] as String?,
);
config = withDynamicConfig(rawConfig)(config);
await compileModsAsync(config, CompileModsOptions(projectRoot: '/path/to/app'));
```

---

## CI/CD integration

In CI, all `${VAR}` references are resolved from the runner's environment — no `.env` file is needed.

### GitHub Actions

```yaml
- name: Apply native config
  env:
    APP_NAME: ${{ secrets.APP_NAME }}
    BUNDLE_ID: ${{ secrets.BUNDLE_ID }}
    APPLICATION_ID: ${{ secrets.APPLICATION_ID }}
    GOOGLE_MAPS_API_KEY: ${{ secrets.GOOGLE_MAPS_API_KEY }}
    FACEBOOK_APP_ID: ${{ secrets.FACEBOOK_APP_ID }}
    FACEBOOK_CLIENT_TOKEN: ${{ secrets.FACEBOOK_CLIENT_TOKEN }}
    BG_GEOLOCATION_LICENSE: ${{ secrets.BG_GEOLOCATION_LICENSE }}
  run: dart run flutter_config_plugin:flutter_config apps/my_app
```

### GitLab CI

Set variables in **Settings → CI/CD → Variables**, then:

```yaml
before_script:
  - flutter pub get
  - dart run flutter_config_plugin:flutter_config apps/my_app
```

---

## Git workflow

The tool writes real API keys into `AndroidManifest.xml` and `Info.plist`, which are git-tracked files. To prevent accidental commits of secrets, mark them as intentionally modified:

```bash
# Run once after cloning
git update-index --skip-worktree \
  android/app/src/main/AndroidManifest.xml \
  ios/Runner/Info.plist \
  ios/Runner/Runner.entitlements
```

Git will never show these files as changed or include them in commits, even though the files are modified on disk.

To temporarily restore tracking (e.g. to update the base file):

```bash
git update-index --no-skip-worktree android/app/src/main/AndroidManifest.xml
# edit the base file (without real secrets), then:
git add android/app/src/main/AndroidManifest.xml && git commit -m "chore: update base manifest"
git update-index --skip-worktree android/app/src/main/AndroidManifest.xml
```

---

## Extending with custom plugins

Register reusable team plugins in `pluginRegistry`:

```dart
pluginRegistry['my-sdk'] = (props) {
  return (config) => withPlugins(config, [
    withMyLicenseKey(props['licenseKey'] as String),
    withMyReceiver(),
  ]);
};
```

Reference them in `flutter_config.yaml`:

```yaml
plugins:
  - name: my-sdk
    props:
      licenseKey: ${MY_SDK_LICENSE}
```

---

## License

MIT
