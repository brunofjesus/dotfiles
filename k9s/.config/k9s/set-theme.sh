#!/bin/bash
# Check if parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <theme>"
    echo "Available themes: latte, mocha, frappe, macchiato"
    exit 1
fi

THEME=$1
SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

# Detect operating system for sed compatibility
OS="$(uname)"

# Validate theme parameter
if [[ "$THEME" != "latte" && "$THEME" != "mocha" && "$THEME" != "frappe" && "$THEME" != "macchiato" ]]; then
    echo "Error: Invalid theme '$THEME'"
    echo "Available themes: latte, mocha, frappe, macchiato"
    exit 1
fi

# Replace the skin line in k9s config
if [[ "$OS" == "Darwin" ]]; then
    # macOS/BSD sed requires empty string after -i
    sed -i '' "s/^    skin: .*/    skin: catppuccin-$THEME/" "$CONFIG_FILE"
else
    # Linux/GNU sed doesn't require empty string after -i
    sed -i "s/^    skin: .*/    skin: catppuccin-$THEME/" "$CONFIG_FILE"
fi

echo "Theme switched to: $THEME"

