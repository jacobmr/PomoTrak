#!/bin/bash

# Configuration
APP_NAME="PomoTrak"
BUILD_DIR=".build/export"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
IDENTITY="Developer ID Application: Jacob Reider (BRLW98HXUE)"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
  echo "Error: App bundle not found at $APP_PATH"
  echo "Please run build-app.sh first"
  exit 1
fi

# Sign the app
echo "Signing $APP_NAME.app..."

# Sign all frameworks and plugins first
find "$APP_PATH/Contents/Frameworks" -name "*.framework" -type d -print0 | while read -d $'\0' framework; do
    codesign --force --verify --verbose --timestamp \
             --sign "$IDENTITY" \
             --options runtime \
             --entitlements "$PWD/entitlements.plist" \
             "$framework"
done

# Sign the main app
codesign --force --verify --verbose --timestamp \
         --sign "$IDENTITY" \
         --options runtime \
         --entitlements "$PWD/entitlements.plist" \
         "$APP_PATH"

# Verify the signature
echo "Verifying signature..."
codesign --verify --deep --verbose=4 "$APP_PATH"
spctl -a -t exec -vv "$APP_PATH"

echo "Signing complete!"
