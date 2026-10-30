#!/usr/bin/env bash
# Deterministic code generation: Pigeon, build_runner, flutter gen-l10n.
set -euo pipefail

cd "$(dirname "$0")/.."

if command -v fvm >/dev/null 2>&1; then
  DART=(fvm dart)
  FLUTTER=(fvm flutter)
else
  DART=(dart)
  FLUTTER=(flutter)
fi

PIGEON_INPUT=packages/native_bridge/pigeons/shell_api.dart
PIGEON_DART_OUT=packages/native_bridge/lib/src/generated/shell_api.g.dart
PIGEON_KOTLIN_OUT=packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/bridge/generated/ShellApi.g.kt
# SPM plugin template layout (DEC-018).
PIGEON_SWIFT_OUT=packages/native_bridge/ios/native_bridge/Sources/native_bridge/Generated/ShellApi.g.swift
PIGEON_KOTLIN_PACKAGE=com.dk.fluttershell.bridge.generated

"${DART[@]}" run pigeon \
  --input "$PIGEON_INPUT" \
  --dart_out "$PIGEON_DART_OUT" \
  --kotlin_out "$PIGEON_KOTLIN_OUT" \
  --kotlin_package "$PIGEON_KOTLIN_PACKAGE" \
  --swift_out "$PIGEON_SWIFT_OUT"

cd apps/shell_app
"${DART[@]}" run build_runner build --delete-conflicting-outputs
"${FLUTTER[@]}" gen-l10n
