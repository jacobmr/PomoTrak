#!/bin/bash

# Build configuration
PRODUCT_NAME="PomoTrak"
BUILD_DIR=".build"
EXPORT_PATH="$BUILD_DIR/Release"
APP_PATH="$EXPORT_PATH/$PRODUCT_NAME.app"

# Clean build directory
echo "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the app
echo "Building $PRODUCT_NAME..."

# First build with SwiftPM to get the binary
swift build -c release --product $PRODUCT_NAME

# Check if build was successful
if [ $? -ne 0 ]; then
  echo "Build failed"
  exit 1
fi

# Create app bundle structure
echo "Creating app bundle..."
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copy the binary
cp "$BUILD_DIR/release/$PRODUCT_NAME" "$APP_PATH/Contents/MacOS/"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$PRODUCT_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.$PRODUCT_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOL

# Sign the app
echo "Signing app..."
codesign --force --verify --verbose --timestamp \
  --sign "Developer ID Application: Jacob Reider (BRLW98HXUE)" \
  --options runtime \
  --entitlements "$PWD/entitlements.plist" \
  "$APP_PATH"

# Verify the signature
echo "Verifying signature..."
codesign --verify --deep --verbose=4 "$APP_PATH"
spctl -a -t exec -vv "$APP_PATH"

echo "Build successful! App is available at: $APP_PATH"
