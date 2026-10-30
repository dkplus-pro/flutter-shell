#!/usr/bin/env bash
# Integration tests. Usage: e2e_android.sh [device]
set -euo pipefail

cd "$(dirname "$0")/../apps/shell_app"

DEVICE="${1:-emulator-5554}"

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi

exec "${FLUTTER[@]}" test integration_test/bridge_e2e_test.dart -d "$DEVICE"
