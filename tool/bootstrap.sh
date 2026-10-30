#!/usr/bin/env bash
# One-shot initialization: FVM check, Flutter install, pub get, codegen.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm not found. Install it first (brew install fvm) and place the" >&2
  echo "Flutter SDK from .fvmrc in ~/fvm/versions/<version>." >&2
  exit 1
fi

FLUTTER_VERSION="$(python3 -c 'import json;print(json.load(open(".fvmrc"))["flutter"])')"
if [ ! -d "$HOME/fvm/versions/$FLUTTER_VERSION" ]; then
  echo "Flutter $FLUTTER_VERSION not cached in ~/fvm/versions; run: fvm install $FLUTTER_VERSION" >&2
  exit 1
fi

fvm flutter pub get
bash tool/gen.sh
echo "bootstrap done"
