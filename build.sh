#!/bin/bash
# Build script for cocoadialog

set -e  # Exit on error

echo "🧹 Cleaning build artifacts..."
xcodebuild clean -workspace cocoadialog.xcworkspace -scheme Release

echo "🔨 Building cocoadialog (Release)..."
xcodebuild build -workspace cocoadialog.xcworkspace -scheme Release

echo "✅ Build complete!"
echo ""
echo "Binary location:"
find ~/Library/Developer/Xcode/DerivedData -name "cocoaDialog" -type f -perm +111 2>/dev/null | grep -E "Release|Build/Products" | head -1
