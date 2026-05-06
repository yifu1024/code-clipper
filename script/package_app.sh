#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="CodeClipper"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
PACKAGE_DIR="$ROOT_DIR/dist/package"
ZIP_PATH="$PACKAGE_DIR/$APP_NAME.zip"

"$ROOT_DIR/script/build_and_run.sh" --verify
pkill -x "$APP_NAME" >/dev/null 2>&1 || true

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"
ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"

echo "Packaged $ZIP_PATH"
