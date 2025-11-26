#!/bin/bash
# Test script that builds, runs cocoadialog, and measures the actual window size

set -e

# Build first
echo "🔨 Building..."
./build.sh

# Find the binary
BINARY=$(find ~/Library/Developer/Xcode/DerivedData -name "cocoadialog" -type f -perm +111 2>/dev/null | grep -E "Release|Build/Products" | head -1)

if [ -z "$BINARY" ]; then
    echo "❌ Could not find built binary"
    exit 1
fi

echo "📦 Using binary: $BINARY"
echo ""

# Run a test dialog in the background
echo "🚀 Launching test dialog..."
"$BINARY" msgbox --title "Test Window" \
    --text "Measuring Window Size" \
    --informative-text "This dialog is for size testing" \
    --button1 "OK" \
    --timeout 30 &

DIALOG_PID=$!

# Wait a moment for window to appear
sleep 2

# Get the window dimensions using AppleScript
echo "📏 Measuring actual window size..."
WINDOW_INFO=$(osascript <<'EOF'
tell application "System Events"
    tell process "cocoadialog"
        try
            set frontWindow to window 1
            set windowSize to size of frontWindow
            set windowPos to position of frontWindow
            return "Position: " & item 1 of windowPos & "x" & item 2 of windowPos & ", Size: " & item 1 of windowSize & "x" & item 2 of windowSize
        on error errMsg
            return "Error: " & errMsg
        end try
    end tell
end tell
EOF
)

echo "🪟 Actual Window: $WINDOW_INFO"
echo ""
echo "📋 Check Console.app for debug output from cocoadialog"
echo "   or run: log stream --predicate 'process == \"cocoadialog\"' --level debug"
echo ""
echo "Dialog will auto-close in 30 seconds or click OK..."

# Wait for dialog to finish
wait $DIALOG_PID 2>/dev/null || true

echo "✅ Done"
