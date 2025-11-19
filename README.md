# cocoaDialog

A macOS utility for displaying native GUI dialogs from command-line scripts and applications.

[![License](https://img.shields.io/badge/license-GPL--2-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)

## Overview

cocoaDialog provides a simple way to display native macOS dialog boxes from shell scripts, Python scripts, or any command-line application. It supports various dialog types including message boxes, input fields, file selection, dropdowns, progress bars, and more.

## Features

- **Multiple Dialog Types**: msgbox, inputbox, dropdown, checkbox, radio, file selection, and more
- **Native macOS UI**: Uses native AppKit controls for proper system integration
- **Shell Script Friendly**: Easy to parse output format for bash/zsh scripts
- **Form Control**: Multi-field input forms with automatic secure field detection
- **Customizable**: Icons, buttons, sizes, and positioning options

## Installation

### From Source

```bash
git clone https://github.com/cocoadialog/cocoadialog.git
cd cocoadialog
open cocoadialog.xcworkspace
# Build in Xcode (Cmd+B)
```

The built application will be in `DerivedData/cocoadialog-*/Build/Products/Release/cocoadialog.app/Contents/MacOS/cocoadialog`

### Usage in Scripts

```bash
# Symlink to a location in your PATH
ln -s /path/to/cocoadialog /usr/local/bin/cocoadialog
```

## Usage Examples

### Message Box

```bash
# Simple message
cocoadialog msgbox --title "Hello" \
  --text "Welcome" \
  --informative-text "This is a message box" \
  --button1 "OK"

# Yes/No question
cocoadialog msgbox --title "Confirm" \
  --text "Delete File?" \
  --informative-text "This cannot be undone" \
  --button1 "Delete" \
  --button2 "Cancel" \
  --icon caution
```

![msgbox preview](https://github.com/jwsmite/cocoadialog/blob/master/Screenshots/msgbox.png)

### Input Box

```bash
# Get user input
result=$(cocoadialog inputbox \
  --title "Name Entry" \
  --informative-text "Please enter your name:" \
  --button1 "OK" \
  --button2 "Cancel")

button=$(echo "$result" | grep "^button:" | awk '{print $2}')
value=$(echo "$result" | grep "^value:" | awk '{print $2}')

if [[ $button == "0" ]]; then
    echo "User entered: $value"
else
    echo "User canceled"
fi
```

### Secure Input (Password)

```bash
result=$(cocoadialog inputbox \
  --title "Authentication" \
  --informative-text "Enter password:" \
  --secure \
  --button1 "Login" \
  --button2 "Cancel")
```

**Note:** This is just looking for the word "password", "pin", "passphrase" or "secret" (case insensitive) in your label/informative-text

### Form (Multi-field Input)

```bash
# Collect multiple values in one dialog
result=$(cocoadialog form \
  --title "User Registration" \
  --label "Full Name" \
  --label "Email Address" \
  --label "Password" \
  --label "Phone Number" \
  --buttons "Register" "Cancel")

# Parse output
button=$(echo "$result" | grep "^button:" | awk '{print $2}')
fullName=$(echo "$result" | grep "^value:" | sed -n '1p' | cut -d' ' -f2-)
email=$(echo "$result" | grep "^value:" | sed -n '2p' | cut -d' ' -f2-)
password=$(echo "$result" | grep "^value:" | sed -n '3p' | cut -d' ' -f2-)
phone=$(echo "$result" | grep "^value:" | sed -n '4p' | cut -d' ' -f2-)

if [[ $button == "0" ]]; then
    echo "Registration submitted"
    echo "Name: $fullName"
    echo "Email: $email"
    # Password field automatically appears as secure (dots)
fi
```
![form preview](https://github.com/jwsmite/cocoadialog/blob/master/Screenshots/form.png) 

**Note**: The form control automatically detects fields that should be secure (password, secret, pin, passphrase) and displays them as password fields.

### Dropdown Menu

```bash
result=$(cocoadialog dropdown \
  --title "Select Environment" \
  --text "Choose deployment target:" \
  --items "Development" "Staging" "Production" \
  --button1 "Deploy" \
  --button2 "Cancel")

button=$(echo "$result" | grep "^button:" | awk '{print $2}')
selection=$(echo "$result" | grep "^value:" | awk '{print $2}')

if [[ $button == "0" ]]; then
    echo "Deploying to: $selection"
fi
```

### File Selection

```bash
# Select a file
result=$(cocoadialog fileselect \
  --title "Choose File" \
  --with-extensions txt pdf doc \
  --button1 "Open")

button=$(echo "$result" | grep "^button:" | awk '{print $2}')
filepath=$(echo "$result" | grep "^value:" | awk '{print $2}')

# Select multiple files
result=$(cocoadialog fileselect \
  --title "Choose Files" \
  --select-multiple)

# Select a directory
result=$(cocoadialog fileselect \
  --title "Choose Folder" \
  --select-directories)
```

### Progress Bar

```bash
# Indeterminate progress
cocoadialog progressbar \
  --title "Processing" \
  --text "Please wait..." \
  --indeterminate &

pid=$!
# Do work...
sleep 5
kill $pid

# Progress with percentage
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
) | cocoadialog progressbar --title "Progress"
```

### Checkbox & Radio

```bash
# Checkboxes (multiple selection)
result=$(cocoadialog checkbox \
  --title "Select Options" \
  --text "Choose features to enable:" \
  --items "Feature A" "Feature B" "Feature C" \
  --checked "Feature A" \
  --button1 "OK")

# Radio buttons (single selection)
result=$(cocoadialog radio \
  --title "Choose One" \
  --text "Select your plan:" \
  --items "Basic" "Pro" "Enterprise" \
  --selected 1 \
  --button1 "Continue")
```

## Common Options

### Available for Most Controls

- `--title "text"` - Window title
- `--text "text"` - Bold header text
- `--informative-text "text"` - Main body text
- `--icon name` - Icon (caution, stop, note, info, document, etc.)
- `--icon-file path` - Custom icon from file
- `--button1 "text"` - Primary button label
- `--button2 "text"` - Secondary button label
- `--button3 "text"` - Tertiary button label
- `--width pixels` - Dialog width
- `--height pixels` - Dialog height
- `--timeout seconds` - Auto-close after timeout
- `--no-cancel` - Disable cancel button
- `--value-required` - Require input before accepting

### Positioning

- `--posX center|left|right|pixels` - Horizontal position
- `--posY center|top|bottom|pixels` - Vertical position

## Output Format

Most controls output in this format:

```
button: <number>
value: <data>
```

- Button numbers: `0` = button1, `1` = button2, `2` = button3
- Some controls output multiple `value:` lines

## Exit Codes

- `0` - Success
- `1` - User canceled
- `51` - Invalid options/validation error
- Other codes indicate specific errors

## Available Controls

| Control         | Description                        |
| --------------- | ---------------------------------- |
| `msgbox`      | Simple message dialog with buttons |
| `inputbox`    | Single-line text input             |
| `form`        | Multi-field input form             |
| `dropdown`    | Dropdown/popup menu selection      |
| `checkbox`    | Multiple selection checkboxes      |
| `radio`       | Single selection radio buttons     |
| `fileselect`  | File/folder picker                 |
| `filesave`    | Save file dialog                   |
| `textbox`     | Multi-line text input              |
| `progressbar` | Progress indicator                 |
| `slider`      | Numeric slider input               |

Use `cocoadialog help` to see all available controls and options.

## Building from Source

### Requirements

- macOS 10.13 or later
- Xcode 14 or later
- CocoaPods

### Build Steps

```bash
# Clone the repository
git clone https://github.com/jwsmite/cocoadialog.git
cd cocoadialog

# Install dependencies
pod install

# Open workspace
open cocoadialog.xcworkspace

# Build (Cmd+B)
# Or build from command line:
xcodebuild -workspace cocoadialog.xcworkspace \
  -scheme cocoadialog \
  -configuration Release \
  build
```

## Recent Improvements

Recent updates to this fork include:

- **New Form Control**: Multi-field input forms with automatic secure field detection
- **Fixed Text Display**: Resolved label rendering issues in dialogs
- **Improved Option Parsing**: Better handling of multi-value and repeatable options
- **Release Build Fixes**: Resolved validation errors in optimized builds
- **Programmatic UI Creation**: Fixed missing controls in dropdown and inputbox
- **Modern macOS Compatibility**: Updated deprecated APIs for current macOS versions
- **Auto-scaling Layouts**: Dialogs automatically resize based on content

*Note: Recent enhancements and bug fixes were developed with AI assistance (Claude by Anthropic), demonstrating effective human-AI collaboration in software development.*

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

cocoaDialog is licensed under GPL-2. See [LICENSE](LICENSE) for details.

## Credits

- Original authors: Mark A. Stratman, Mark Carver
- Contributors: See [GitHub contributors](https://github.com/cocoadialog/cocoadialog/graphs/contributors)
- Recent improvements: Enhanced with AI assistance

## Example Use Cases

### Backup Script with Progress

```bash
#!/bin/bash
files=(file1 file2 file3 file4 file5)
total=${#files[@]}

for i in "${!files[@]}"; do
    percent=$((i * 100 / total))
    echo "$percent Backing up ${files[$i]}..."
    # Actual backup command here
    sleep 1
done | cocoadialog progressbar --title "Backup" --text "Backing up files..."

cocoadialog msgbox --title "Complete" \
  --text "Backup Finished" \
  --informative-text "All files backed up successfully" \
  --icon info --button1 "OK"
```

### Configuration Wizard

```bash
#!/bin/bash

# Get user input
result=$(cocoadialog form \
  --title "Setup Wizard" \
  --label "Server Address" \
  --label "API Key" \
  --label "Username" \
  --label "Password" \
  --value "https://api.example.com" \
  --buttons "Connect" "Cancel")

button=$(echo "$result" | grep "^button:" | awk '{print $2}')

if [[ $button == "1" ]]; then
    echo "Setup canceled"
    exit 1
fi

# Parse values
server=$(echo "$result" | grep "^value:" | sed -n '1p' | cut -d' ' -f2-)
apikey=$(echo "$result" | grep "^value:" | sed -n '2p' | cut -d' ' -f2-)
user=$(echo "$result" | grep "^value:" | sed -n '3p' | cut -d' ' -f2-)
pass=$(echo "$result" | grep "^value:" | sed -n '4p' | cut -d' ' -f2-)

# Save configuration
cat > config.ini <<EOF
server=$server
apikey=$apikey
username=$user
password=$pass
EOF

cocoadialog msgbox --title "Success" \
  --text "Configuration Saved" \
  --icon info --button1 "OK"
```

---

**Note**: This is a modified fork with some modernization. For the original project, see [cocoadialog.com](https://cocoadialog.com).
