#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p packaging

bash scripts/stage.sh
bash scripts/package-deb.sh
bash scripts/package-rpm.sh
bash scripts/package-appimage.sh
bash scripts/package-tar.sh
