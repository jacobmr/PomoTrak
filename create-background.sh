#!/bin/bash

# Create a simple background image for the DMG
convert -size 600x400 xc:white \
  -fill '#007AFF' -draw 'rectangle 0,0 600,80' \
  -fill white -pointsize 36 -gravity north -annotate +0+20 "$PRODUCT_NAME $VERSION" \
  -pointsize 14 -fill black -gravity center -annotate +0+40 "Drag $PRODUCT_NAME to the Applications folder" \
  background.png
