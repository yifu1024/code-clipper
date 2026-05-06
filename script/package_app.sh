#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="CodeClipper"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
PACKAGE_DIR="$ROOT_DIR/dist/package"
ZIP_PATH="$PACKAGE_DIR/$APP_NAME.zip"
DMG_STAGING="$PACKAGE_DIR/dmg-staging"
DMG_PATH="$PACKAGE_DIR/$APP_NAME.dmg"

"$ROOT_DIR/script/build_app.sh"
pkill -x "$APP_NAME" >/dev/null 2>&1 || true

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR" "$DMG_STAGING"
ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"

cp -R "$APP_BUNDLE" "$DMG_STAGING/$APP_NAME.app"
ln -s /Applications "$DMG_STAGING/Applications"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

rm -rf "$DMG_STAGING"

echo "Packaged $ZIP_PATH"
echo "Packaged $DMG_PATH"
