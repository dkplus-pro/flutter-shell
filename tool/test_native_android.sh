#!/usr/bin/env bash
# Android unit tests (JVM): :app + :native_bridge via Gradle.
set -euo pipefail

cd "$(dirname "$0")/.."

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi

if [ ! -f apps/shell_app/android/local.properties ]; then
  echo "local.properties missing; generating via debug build"
  (cd apps/shell_app && "${FLUTTER[@]}" build apk --debug)
fi

cd apps/shell_app/android
./gradlew testDebugUnitTest
