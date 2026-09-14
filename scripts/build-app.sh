#!/bin/bash
set -euo pipefail

APP_NAME="TomatoTimer"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
DIST_DIR="$ROOT_DIR/dist"

cd "$ROOT_DIR"

swift build

rm -rf "$DIST_DIR/$APP_NAME.app"
mkdir -p "$DIST_DIR/$APP_NAME.app/Contents/MacOS"

cp "$BUILD_DIR/debug/tomato_timer" "$DIST_DIR/$APP_NAME.app/Contents/MacOS/"

cat > "$DIST_DIR/$APP_NAME.app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleExecutable</key>
	<string>tomato_timer</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.tomato-timer</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>TomatoTimer</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSUserNotificationUsageDescription</key>
	<string>在番茄钟结束或休息结束时向您发送系统通知。</string>
</dict>
</plist>
PLIST

mkdir -p "$DIST_DIR/$APP_NAME.app/Contents/Resources"
if [ -f "$ROOT_DIR/Resources/AppIcon.icns" ]; then
    cp "$ROOT_DIR/Resources/AppIcon.icns" "$DIST_DIR/$APP_NAME.app/Contents/Resources/"
fi

codesign -f -s - "$DIST_DIR/$APP_NAME.app"

echo "Built: $DIST_DIR/$APP_NAME.app"