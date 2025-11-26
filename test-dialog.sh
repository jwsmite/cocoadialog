#!/bin/bash

# Test script for cocoadialog
CD="/Users/jsmit/Library/Developer/Xcode/DerivedData/cocoadialog-gwwrlwshqpyalnezjzpgoegcvgem/Build/Products/Release/cocoadialog.app/Contents/MacOS/cocoadialog"

if [ ! -f "$CD" ]; then
    echo "ERROR: cocoadialog not found at:"
    echo "$CD"
    echo ""
    echo "Please build the project in Xcode first."
    exit 1
fi

# Run the test
echo "Testing: $1"
case "$1" in
    "simple")
        "$CD" msgbox --title "Test" --header "Header Text" --message "This is a simple message" --button1 "OK"
        ;;
    "long")
        "$CD" inputbox --title "Configuration" --header "Enter API Key" \
            --message "Please enter your API key. This key is used to authenticate your application with our services. You can find this key in your account dashboard under Settings > API Access > Generate Key. The key should be 64 characters long." \
            --button1 "Save" --button2 "Cancel"
        ;;
    "form")
        "$CD" form --title "Registration" --header "Please fill out all fields" \
            --message "Complete this form" \
            --label "Full Name:" --label "Email:" --label "Phone:" --label "Address:" \
            --label "City:" --label "State:" --label "Zip:" --label "Country:" \
            --button1 "Submit" --button2 "Cancel"
        ;;
    *)
        echo "Usage: $0 {simple|long|form}"
        echo ""
        echo "  simple - Simple msgbox test"
        echo "  long   - Long text wrapping test"
        echo "  form   - 8-field form test"
        exit 1
        ;;
esac
