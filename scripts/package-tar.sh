#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh

tar -czf \
  "packaging/${APP_NAME}-${VERSION}-linux-x86_64.tar.gz" \
  -C build/linux/x64/release \
  bundle

echo "Built packaging/${APP_NAME}-${VERSION}-linux-x86_64.tar.gz"
