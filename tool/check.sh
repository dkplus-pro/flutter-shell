#!/usr/bin/env bash
# Static gate: format (hand-written Dart only), import boundaries, analyze.
set -euo pipefail

cd "$(dirname "$0")/.."

if command -v fvm >/dev/null 2>&1; then
  DART=(fvm dart)
  FLUTTER=(fvm flutter)
else
  DART=(dart)
  FLUTTER=(flutter)
fi

# Format only hand-written files; never touch generated output.
HANDWRITTEN="$(find apps packages \
  -name '*.dart' -type f \
  ! -name '*.g.dart' \
  ! -path '*/l10n/generated/*' \
  ! -path '*/src/generated/*' \
  ! -path '*/pigeons/*' \
  ! -path '*/.dart_tool/*')"

if [ -n "$HANDWRITTEN" ]; then
  # shellcheck disable=SC2086
  echo "$HANDWRITTEN" | xargs "${DART[@]}" format --set-exit-if-changed
fi

bash tool/check_imports.sh

for p in apps/shell_app packages/app_core packages/app_ui packages/native_bridge; do
  echo "== analyze $p"
  (cd "$p" && "${FLUTTER[@]}" analyze --fatal-infos)
done
echo "check done"
