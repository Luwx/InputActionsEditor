#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh

# Manual COPR publish from a local machine. The GitHub release workflow does the
# same thing automatically on a `v*` tag — use this only for out-of-band builds.
#
# Changelog entries come from CHANGELOG.md (single source of truth): put the
# release notes under the top `[Unreleased]` (or `[<version>]`) section before
# running this. package-copr.sh regenerates the spec %changelog from it.

SPEC="packaging/input-actions-editor.spec"
COPR_PROJECT="${COPR_PROJECT:-input-actions-editor}"

# Determine release number: reset to 1 on version bump, otherwise increment.
SPEC_VERSION=$(grep '^Version:' "$SPEC" | sed 's/Version:[[:space:]]*//')
CURRENT_RELEASE=$(grep '^Release:' "$SPEC" | sed 's/Release:[[:space:]]*//' | sed 's/%{?dist}//')
if [[ "$SPEC_VERSION" == "$VERSION" ]]; then
  export RELEASE=$((CURRENT_RELEASE + 1))
else
  export RELEASE=1
fi

echo "Publishing ${VERSION}-${RELEASE} to COPR project '${COPR_PROJECT}'"

echo ""
echo "==> Building Flutter app..."
scripts/build.sh

echo ""
echo "==> Staging..."
scripts/stage.sh

echo ""
echo "==> Building SRPM (changelog generated from CHANGELOG.md)..."
scripts/package-copr.sh

echo ""
echo "==> Uploading to COPR..."
SRPM=$(ls packaging/input-actions-editor-${VERSION}-*.src.rpm | tail -1)
copr-cli build "$COPR_PROJECT" "$SRPM"

echo ""
echo "Done! ${VERSION}-${RELEASE} submitted to COPR: $COPR_PROJECT"
