#!/bin/bash

# Test script for progressbar functionality

echo "Testing CocoaDialog progressbar with updates..."

# Test 1: Basic progress with updates
(
    for i in {10..100..10}; do
        echo "$i Processing $i%..."
        sleep 0.3
    done
) | ./cocoadialog progressbar --title "Progress Test" --text "Testing progress updates" --stoppable

echo ""
echo "Test complete!"
echo ""
echo "Expected behavior:"
echo "- Progress bar should fill from 0% to 100%"
echo "- Text should update with each progress step"  
echo "- 'Stop' button should be clickable and cancel the operation"
