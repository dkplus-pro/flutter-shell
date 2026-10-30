#!/usr/bin/env bash
# Dart tests for every package that has a test directory.
set -euo pipefail

cd "$(dirname "$0")/.."

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi

failed=0
for p in apps/shell_app packages/app_core packages/app_ui packages/native_bridge; do
  if [ -d "$p/test" ] && [ -n "$(find "$p/test" -name '*_test.dart' -type f -print -quit)" ]; then
    echo "== test $p"
    (cd "$p" && "${FLUTTER[@]}" test) || failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  echo "test: FAILED" >&2
  exit 1
fi
echo "test done"
