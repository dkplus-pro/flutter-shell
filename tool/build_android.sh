#!/usr/bin/env bash
# Build the Android APK. Usage: build_android.sh [--release]
set -euo pipefail

cd "$(dirname "$0")/../apps/shell_app"

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi

if [ "${1:-}" = "--release" ]; then
  # APP_ENV=prod is mandatory for release builds (DEC-007).
  "${FLUTTER[@]}" build apk --release \
    --split-per-abi \
    --obfuscate \
    --split-debug-info=build/symbols \
    --dart-define=APP_ENV=prod
else
  "${FLUTTER[@]}" build apk --debug --dart-define=APP_ENV=dev
fi
