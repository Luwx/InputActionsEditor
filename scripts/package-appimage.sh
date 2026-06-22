#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh

export APPIMAGE_EXTRACT_AND_RUN=1

rm -rf "$APPDIR"
mkdir -p "$APPDIR/bundle"
cp -r "$BUNDLE"/. "$APPDIR/bundle/"

{
  echo '#!/bin/bash'
  echo 'SELF=$(readlink -f "$0")'
  echo 'HERE=${SELF%/*}'
  printf 'exec "$HERE/bundle/%s" "$@"\n' "$BINARY_NAME"
} > "$APPDIR/AppRun"
chmod +x "$APPDIR/AppRun"

cp "linux/$APP_ID.desktop" "$APPDIR/"
cp "linux/icons/256x256/apps/$APP_ID.png" "$APPDIR/$APP_ID.png"

appimagetool "$APPDIR" \
  "packaging/${APP_NAME}-${VERSION}-x86_64.AppImage"

echo "Built packaging/${APP_NAME}-${VERSION}-x86_64.AppImage"
