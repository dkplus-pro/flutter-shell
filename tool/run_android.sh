#!/usr/bin/env bash
# Run the app. Usage: run_android.sh [device]
set -euo pipefail

cd "$(dirname "$0")/../apps/shell_app"

DEVICE="${1:-emulator-5554}"

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi

exec "${FLUTTER[@]}" run -d "$DEVICE" --dart-define=APP_ENV=dev
