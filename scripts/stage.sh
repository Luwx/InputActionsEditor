#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh

rm -rf "$STAGE"

mkdir -p "$STAGE/opt/$APP_NAME"
cp -r "$BUNDLE"/. "$STAGE/opt/$APP_NAME/"

mkdir -p "$STAGE/usr/bin"
{
  echo '#!/bin/sh'
  printf 'exec /opt/%s/%s "$@"\n' "$APP_NAME" "$BINARY_NAME"
} > "$STAGE/usr/bin/$BINARY_NAME"
chmod +x "$STAGE/usr/bin/$BINARY_NAME"

mkdir -p "$STAGE/usr/share/applications"
cp "linux/$APP_ID.desktop" "$STAGE/usr/share/applications/"

for size in 16 32 48 64 128 256 512; do
  mkdir -p "$STAGE/usr/share/icons/hicolor/${size}x${size}/apps"
  cp "linux/icons/${size}x${size}/apps/$APP_ID.png" \
     "$STAGE/usr/share/icons/hicolor/${size}x${size}/apps/"
done

rm -f "$STAGE/opt/$APP_NAME/data/flutter_assets/kernel_blob.bin"

echo "Staged to $STAGE"
