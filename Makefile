APP_DIR := apps/flutter_package

# ─────────────────────────────────────────────────────────────────────────────
# First-time setup (run this once after cloning)
# ─────────────────────────────────────────────────────────────────────────────
setup:
	@echo "==> flutter pub get"
	@flutter pub get
	@if [ ! -f $(APP_DIR)/.env ]; then \
		cp $(APP_DIR)/.env.example $(APP_DIR)/.env; \
		echo ""; \
		echo "  ⚠️  Created $(APP_DIR)/.env from .env.example"; \
		echo "  ✏️  Open that file and fill in real values before continuing."; \
		echo ""; \
		exit 1; \
	fi
	@$(MAKE) config
	@echo "==> Marking native files as skip-worktree in git"
	@git update-index --skip-worktree \
		$(APP_DIR)/android/app/src/main/AndroidManifest.xml \
		$(APP_DIR)/ios/Runner/Info.plist \
		$(APP_DIR)/ios/Runner/Runner.entitlements 2>/dev/null || true
	@echo ""
	@echo "✅  Setup complete. Run: make run"

# ─────────────────────────────────────────────────────────────────────────────
# Config tool (inject .env values into AndroidManifest.xml + Info.plist)
# ─────────────────────────────────────────────────────────────────────────────
config:
	@echo "==> Applying flutter_config.yaml → native files..."
	@dart run flutter_config_plugin:flutter_config $(APP_DIR)
	@echo "==> Done."

config-dry:
	@dart run flutter_config_plugin:flutter_config $(APP_DIR) --dry-run

config-check:
	@dart run flutter_config_plugin:flutter_config $(APP_DIR) --check

# ─────────────────────────────────────────────────────────────────────────────
# Dev — run app
# ─────────────────────────────────────────────────────────────────────────────
run: config
	@cd $(APP_DIR) && flutter run

run-ios: config
	@cd $(APP_DIR) && flutter run --config-only --platforms ios || true
	@cd $(APP_DIR) && flutter run -d "iPhone"

run-android: config
	@cd $(APP_DIR) && flutter run -d "emulator"

# ─────────────────────────────────────────────────────────────────────────────
# Release builds
# ─────────────────────────────────────────────────────────────────────────────
build-android: config
	@cd $(APP_DIR) && flutter build apk --release

build-android-aab: config
	@cd $(APP_DIR) && flutter build appbundle --release

build-ios: config
	@cd $(APP_DIR) && flutter build ios --release --no-codesign

# ─────────────────────────────────────────────────────────────────────────────
# Reset native files to their base version (useful for a clean git diff)
# ─────────────────────────────────────────────────────────────────────────────
reset-native:
	@git checkout -- \
		$(APP_DIR)/android/app/src/main/AndroidManifest.xml \
		$(APP_DIR)/ios/Runner/Info.plist 2>/dev/null || true
	@echo "==> Native files reset to base version."

.PHONY: setup config config-dry config-check run run-ios run-android \
        build-android build-android-aab build-ios reset-native
