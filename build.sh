#!/bin/bash
# Build script for cocoadialog

set -e  # Exit on error

echo "🧹 Cleaning build artifacts..."
xcodebuild clean -workspace cocoadialog.xcworkspace -scheme Release

echo "🔨 Building cocoadialog (Release)..."
xcodebuild build -workspace cocoadialog.xcworkspace -scheme Release

echo "✅ Build complete!"
echo ""
echo "Application bundle:"
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "cocoadialog.app" -type d 2>/dev/null | grep -E "Release" | head -1)
if [ -n "$APP_PATH" ]; then
    echo "$APP_PATH"
    echo ""
    echo "Binary:"
    echo "$APP_PATH/Contents/MacOS/cocoadialog"
else
    echo "❌ Could not find cocoadialog.app"
fi
