#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-0.1.0}"
APP="$ROOT/build/Small Count.app"
DIST="$ROOT/dist"
DMG="$DIST/Small-Count-v${VERSION}-macos.dmg"
CHECKSUM="$DMG.sha256"
STAGING="$(mktemp -d "${TMPDIR:-/tmp}/small-count-dmg-XXXXXX")"

cleanup() {
    rm -rf "$STAGING"
}
trap cleanup EXIT

"$ROOT/Scripts/package_app.sh"
mkdir -p "$DIST"
rm -f "$DMG" "$CHECKSUM"
/usr/bin/ditto "$APP" "$STAGING/Small Count.app"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
    -volname "Small Count" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "$DMG"

hdiutil verify "$DMG"
(
    cd "$DIST"
    shasum -a 256 "$(basename "$DMG")" > "$(basename "$CHECKSUM")"
)

printf 'DMG: %s\nSHA256: %s\n' "$DMG" "$CHECKSUM"
