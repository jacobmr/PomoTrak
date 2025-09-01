#!/bin/bash

# Configuration
PRODUCT_NAME="PomoTrak"
VERSION="1.0.0"
BUILD_DIR=".build"
EXPORT_PATH="$BUILD_DIR/export"
APP_PATH="$EXPORT_PATH/$PRODUCT_NAME.app"
DMG_NAME="${PRODUCT_NAME}-${VERSION}.dmg"
DMG_PATH="$BUILD_DIR/$DMG_NAME"
VOLUME_NAME="$PRODUCT_NAME $VERSION"
BACKGROUND_IMG="$PWD/background.png"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
  echo "Error: App bundle not found at $APP_PATH"
  echo "Please run build-app.sh first"
  exit 1
fi

# Create a temporary directory for DMG contents
echo "Preparing DMG contents..."
DMG_TEMP_DIR="$BUILD_DIR/dmg-temp"
rm -rf "$DMG_TEMP_DIR"
mkdir -p "$DMG_TEMP_DIR"

# Copy the app to the temp directory
cp -R "$APP_PATH" "$DMG_TEMP_DIR/"

# Create a symlink to Applications
ln -s "/Applications" "$DMG_TEMP_DIR/Applications"

# Create a background directory and copy the background image
mkdir -p "$DMG_TEMP_DIR/.background"
if [ -f "$BACKGROUND_IMG" ]; then
  cp "$BACKGROUND_IMG" "$DMG_TEMP_DIR/.background/background.png"
fi

# Calculate the size needed for the DMG
APP_SIZE=$(du -sm "$DMG_TEMP_DIR" | cut -f1)
DMG_SIZE=$(($APP_SIZE + 20)) # Add 20MB for extra space

# Create the DMG
echo "Creating DMG..."
rm -f "$DMG_PATH"

# Create the DMG with create-dmg
create-dmg \
  --volname "$VOLUME_NAME" \
  --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
  --background "$DMG_TEMP_DIR/.background/background.png" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "$PRODUCT_NAME.app" 150 190 \
  --hide-extension "$PRODUCT_NAME.app" \
  --app-drop-link 450 190 \
  --no-internet-enable \
  "$DMG_PATH" \
  "$DMG_TEMP_DIR/"

# Clean up
rm -rf "$DMG_TEMP_DIR"

# Check if DMG was created successfully
if [ -f "$DMG_PATH" ]; then
  echo "DMG created successfully at: $DMG_PATH"
  
  # Sign the DMG if a Developer ID Installer certificate is available
  if security find-identity -v | grep -q "Developer ID Installer"; then
    echo "Signing DMG with Developer ID Installer certificate..."
    SIGNING_IDENTITY=$(security find-identity -v | grep "Developer ID Installer" | head -n1 | awk '{print $2}')
    codesign --force --sign "$SIGNING_IDENTITY" --timestamp --options runtime "$DMG_PATH"
    
    # Notarize the DMG
    echo "Notarizing DMG..."
    xcrun notarytool submit "$DMG_PATH" \
      --keychain-profile "AC_PASSWORD" \
      --wait
    
    # Staple the ticket to the DMG
    echo "Stapling ticket to DMG..."
    xcrun stapler staple "$DMG_PATH"
  else
    echo "No Developer ID Installer certificate found. DMG was not signed or notarized."
  fi
  
  echo "DMG is ready at: $DMG_PATH"
else
  echo "Failed to create DMG"
  exit 1
fi
