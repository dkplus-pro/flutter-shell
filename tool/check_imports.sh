#!/usr/bin/env bash
# Dependency boundary gate (docs/01 §4): R1-R4 with the DEC-019 router
# exception. Prints violations with file:line and exits 1.
set -euo pipefail

cd "$(dirname "$0")/.."

violations=0

fail() {
  echo "violation: $1" >&2
  violations=$((violations + 1))
}

if command -v rg >/dev/null 2>&1; then
  SEARCH="rg -n --no-heading"
else
  SEARCH="grep -R -n -I"
fi

glob_args=()
if [ "$SEARCH" != "grep -R -n -I" ]; then
  glob_args=(--glob '!**/*.g.dart' --glob '!**/l10n/generated/**' --glob '!**/src/generated/**')
fi

scan() {
  # scan <paths...> -- <pattern>
  local pattern="$*"
  if [ "$SEARCH" != "grep -R -n -I" ]; then
    $SEARCH "${glob_args[@]}" "$pattern" "${SCAN_PATHS[@]}" 2>/dev/null || true
  else
    local includes=""
    for g in "**/*.dart"; do
      :
    done
    find "${SCAN_PATHS[@]}" -name '*.dart' \
      ! -path '*/*.g.dart' \
      ! -path '*/l10n/generated/*' \
      ! -path '*/src/generated/*' \
      -type f | while read -r file; do
      grep -H -n "$pattern" "$file" 2>/dev/null || true
    done
  fi
}

# R1: packages/** must not import the app.
SCAN_PATHS=(packages)
while read -r line; do [ -n "$line" ] && fail "$line"; done < <(
  scan 'package:fluttershell/'
)

# R2: packages/** must not depend on Riverpod.
SCAN_PATHS=(packages)
while read -r line; do [ -n "$line" ] && fail "$line"; done < <(
  scan -e 'package:flutter_riverpod/' -e 'package:riverpod/'
)

# R3: shell_app core must not import features (DEC-019: router excepted).
SCAN_PATHS=(apps/shell_app/lib/core)
while read -r line; do
  case "$line" in
    apps/shell_app/lib/core/router/app_router.dart*) ;;
    *) [ -n "$line" ] && fail "$line" ;;
  esac
done < <(scan "features/")

# R4: a feature must not import another feature.
SCAN_PATHS=(apps/shell_app/lib/features)
while read -r line; do
  [ -n "$line" ] || continue
  importer="$(echo "$line" | cut -d: -f1)"
  offender="$(echo "$line" | cut -d: -f2-)"
  case "$importer" in
    apps/shell_app/lib/features/home/*)
      case "$offender" in
        *features/home/*) ;;
        *) fail "$line" ;;
      esac
      ;;
    apps/shell_app/lib/features/bridge_demo/*)
      case "$offender" in
        *features/bridge_demo/*) ;;
        *) fail "$line" ;;
      esac
      ;;
    *) fail "$line" ;;
  esac
done < <(scan "features/")

if [ "$violations" -gt 0 ]; then
  echo "check_imports: $violations violation(s)" >&2
  exit 1
fi
echo "check_imports: OK"
