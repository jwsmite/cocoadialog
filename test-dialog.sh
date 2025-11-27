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
    "dropdown")
        "$CD" dropdown --title "Select Environment" \
            --text "Choose deployment target:" \
            --items "Development" "Staging" "Production" "QA" "Demo" \
            --button1 "Deploy" --button2 "Cancel"
        ;;
    "slider")
        "$CD" slider --title "Volume Control" \
            --text "Adjust audio volume:" \
            --min 0 --max 100 --value 50 \
            --always-show-value \
            --button1 "Set" --button2 "Cancel"
        ;;
    "textbox")
        "$CD" textbox --title "Comments" \
            --text "Please provide feedback:" \
            --informative-text "Enter your comments below (supports multiple lines)" \
            --editable \
            --button1 "Submit" --button2 "Cancel"
        ;;
    "progressbar")
        echo "Testing indeterminate progress..."
        "$CD" progressbar --title "Processing" --text "Please wait..." --indeterminate --stoppable &
        PID=$!
        sleep 3
        kill $PID 2>/dev/null
        
        echo ""
        echo "Testing progress with percentage..."
        (
            echo "0 Starting..."
            sleep 1
            echo "25 Processing files..."
            sleep 1
            echo "50 Half done..."
            sleep 1
            echo "75 Almost there..."
            sleep 1
            echo "100 Complete!"
        ) | "$CD" progressbar --title "Progress" --text "Working..." --stoppable
        ;;
    "fileselect")
        "$CD" fileselect --title "Choose a File" \
            --with-extensions txt md pdf \
            --button1 "Open"
        ;;
    "filesave")
        "$CD" filesave --title "Save Document" \
            --with-file "untitled.txt" \
            --button1 "Save"
        ;;
    *)
        echo "Usage: $0 {simple|long|form|dropdown|slider|textbox|progressbar|fileselect|filesave}"
        echo ""
        echo "  simple      - Simple msgbox test"
        echo "  long        - Long text wrapping test"
        echo "  form        - 8-field form test"
        echo "  dropdown    - Dropdown menu test"
        echo "  slider      - Slider input test"
        echo "  textbox     - Multi-line text input"
        echo "  progressbar - Progress indicator test"
        echo "  fileselect  - File selection dialog"
        echo "  filesave    - Save file dialog"
        echo ""
        echo "Note: checkbox and radio dialogs require matrix NIB support (not currently available)"
        exit 1
        ;;
esac
