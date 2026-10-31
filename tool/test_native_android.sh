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
# 只跑自有模块，避免第三方插件（如 shared_preferences_android）的 Robolectric 测试
# 依赖 Java 21 而拖垮 CI。
./gradlew :app:testDebugUnitTest :native_bridge:testDebugUnitTest
