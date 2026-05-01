# Changelog

## v0.0.2-beta

### Improvements

- Fix static analysis issues to improve pub.dev score (dangling library doc comments, angle brackets in doc comments, string interpolation)
- Add `analysis_options.yaml` with `lints/recommended` for consistent local analysis
- Export `android_plugins.dart` from public API (previously missing)
- Add dartdoc comments and private constructor to `AndroidPermissions`
- Add doc to `AndroidOrientation.value`
- Example rewritten to use `withGenericConfig` for both iOS and Android

---

## v0.0.1-beta

Initial beta release.

### Features

- YAML-driven config pipeline — declare all native file changes in `flutter_config.yaml`, no Dart code required
- `generic.ios` — supports `infoPlist`, `permissions` (NSXxx shortcuts), `backgroundModes`, `urlSchemes`, `queriesSchemes`, `entitlements`
- `generic.android` — supports `permissions`, `features`, `strings`, `manifest.applicationAttributes`, `meta-data`, `services`, `receivers`, `activities`, `providers`, `queries`
- `${VAR}` interpolation everywhere — resolved from `.env` (dev) or `Platform.environment` (CI) with no code changes
- CLI tool: `dart run flutter_config_plugin:flutter_config [project_root]`
  - `--dry-run` — preview without writing files
  - `--check` — validate required env vars
  - `--platforms ios,android` — restrict target platforms
- Idempotent — safe to run on every build
- Dart API for custom mods (`withInfoPlist`, `withAndroidManifest`, `withEntitlements`, etc.)
- Plugin registry for reusable team plugins (`pluginRegistry`)
