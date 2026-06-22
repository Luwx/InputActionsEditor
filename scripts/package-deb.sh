#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh

fpm -s dir -t deb \
  --name "$APP_NAME" \
  --version "$VERSION" \
  --architecture amd64 \
  --description "Input Actions configurator for managing shortcuts and input bindings." \
  --maintainer "Luwx" \
  --depends "libgtk-3-0 (>= 3.24)" \
  --depends libglib2.0-0 \
  --depends libstdc++6 \
  --deb-compression xz \
  --package "packaging/${APP_NAME}_${VERSION}_amd64.deb" \
  -C "$STAGE" \
  .

echo "Built packaging/${APP_NAME}_${VERSION}_amd64.deb"
