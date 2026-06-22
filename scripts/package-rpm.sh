#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh

fpm -s dir -t rpm \
  --name "$APP_NAME" \
  --version "$VERSION" \
  --architecture x86_64 \
  --description "Input Actions configurator for managing shortcuts and input bindings." \
  --maintainer "Luwx" \
  --depends gtk3 \
  --depends glib2 \
  --depends libstdc++ \
  --package "packaging/${APP_NAME}-${VERSION}-x86_64.rpm" \
  -C "$STAGE" \
  .

echo "Built packaging/${APP_NAME}-${VERSION}-x86_64.rpm"
