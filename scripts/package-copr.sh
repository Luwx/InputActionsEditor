#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh

SPEC_TEMPLATE="packaging/input-actions-editor.spec"
TARBALL="${APP_NAME}-${VERSION}.tar.gz"
RELEASE="${RELEASE:-1}"

mkdir -p packaging

if [[ ! -d "$STAGE" ]]; then
  echo "Stage directory not found. Run scripts/stage.sh first." >&2
  exit 1
fi

# Update version/release in spec file
sed -i "s/^Version:.*/Version:        ${VERSION}/" "$SPEC_TEMPLATE"
sed -i "s/^Release:.*/Release:        ${RELEASE}%{?dist}/" "$SPEC_TEMPLATE"

# Regenerate the %changelog section from CHANGELOG.md (single source of truth).
if [[ -f CHANGELOG.md ]]; then
  echo "Generating spec changelog from CHANGELOG.md..."
  CHANGELOG_BLOCK=$(python3 scripts/gen-spec-changelog.py CHANGELOG.md "$VERSION" "$RELEASE")
  awk -v block="$CHANGELOG_BLOCK" '
    /^%changelog/ { print; print block; exit }
    { print }
  ' "$SPEC_TEMPLATE" > "$SPEC_TEMPLATE.tmp" && mv "$SPEC_TEMPLATE.tmp" "$SPEC_TEMPLATE"
fi

# Create source tarball with the required top-level directory <name>-<version>/
# so that %setup -q in the spec file can unpack it correctly.
echo "Creating source tarball..."
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cp -r "$STAGE/." "$TMPDIR/${APP_NAME}-${VERSION}/"
tar czf "packaging/${TARBALL}" -C "$TMPDIR" "${APP_NAME}-${VERSION}"

# Set up rpmbuild tree
mkdir -p ~/rpmbuild/{SOURCES,SPECS,SRPMS}
cp "packaging/${TARBALL}" ~/rpmbuild/SOURCES/
cp "$SPEC_TEMPLATE" ~/rpmbuild/SPECS/

# Build SRPM
echo "Building SRPM..."
rpmbuild -bs ~/rpmbuild/SPECS/input-actions-editor.spec

SRPM=$(ls ~/rpmbuild/SRPMS/input-actions-editor-${VERSION}-*.src.rpm | tail -1)
cp "$SRPM" packaging/

echo ""
echo "SRPM ready: packaging/$(basename "$SRPM")"
echo ""
echo "Upload to COPR:"
echo "  copr-cli build <your-project> packaging/$(basename "$SRPM")"
echo "  -- or -- upload manually at https://copr.fedorainfracloud.org"
