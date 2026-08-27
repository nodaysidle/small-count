#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"
APP_PATH="$ROOT/build/Small Count.app"
CONTENTS="$APP_PATH/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
PLIST="$CONTENTS/Info.plist"
ICON="$ROOT/Resources/AppIcon.icns"
LOGO="$ROOT/Resources/AppIcon.svg"

test -f "$ICON" || { echo "Missing icon: $ICON" >&2; exit 1; }
test -f "$LOGO" || { echo "Missing logo: $LOGO" >&2; exit 1; }

rm -rf "$APP_PATH"
mkdir -p "$MACOS" "$RESOURCES"
install -m 755 "$BIN_DIR/SmallCount" "$MACOS/SmallCount"
install -m 644 "$ICON" "$RESOURCES/AppIcon.icns"
install -m 644 "$LOGO" "$RESOURCES/AppIcon.svg"
printf 'APPL????' > "$CONTENTS/PkgInfo"

/usr/bin/plutil -create xml1 "$PLIST"
/usr/bin/plutil -insert CFBundleName -string "Small Count" "$PLIST"
/usr/bin/plutil -insert CFBundleDisplayName -string "Small Count" "$PLIST"
/usr/bin/plutil -insert CFBundleExecutable -string SmallCount "$PLIST"
/usr/bin/plutil -insert CFBundleIdentifier -string com.nodaysidle.smallcount "$PLIST"
/usr/bin/plutil -insert CFBundleIconFile -string AppIcon "$PLIST"
/usr/bin/plutil -insert CFBundlePackageType -string APPL "$PLIST"
/usr/bin/plutil -insert CFBundleShortVersionString -string 0.1.0 "$PLIST" # CFBundleShortVersionString 0.1.0
/usr/bin/plutil -insert CFBundleVersion -string 1 "$PLIST" # CFBundleVersion 1
/usr/bin/plutil -insert LSMinimumSystemVersion -string 15.0 "$PLIST" # LSMinimumSystemVersion 15.0
/usr/bin/plutil -insert LSUIElement -bool true "$PLIST" # LSUIElement true
/usr/bin/plutil -insert NSHighResolutionCapable -bool true "$PLIST"

/usr/bin/xattr -cr "$APP_PATH"
/usr/bin/codesign --force --deep --sign - "$APP_PATH"
/usr/bin/codesign --verify --deep --strict "$APP_PATH"

echo "Packaged: build/Small Count.app"
