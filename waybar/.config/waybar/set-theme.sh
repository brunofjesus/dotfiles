#!/bin/bash

# Check if parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <theme>"
    echo "Available themes: latte, mocha, frappe"
    exit 1
fi

THEME=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSS_FILE="$SCRIPT_DIR/style.css"

# Validate theme parameter
if [[ "$THEME" != "latte" && "$THEME" != "mocha" && "$THEME" != "frappe" ]]; then
    echo "Error: Invalid theme '$THEME'"
    echo "Available themes: latte, mocha, frappe"
    exit 1
fi

# Check if style.css exists
if [ ! -f "$CSS_FILE" ]; then
    echo "Error: $CSS_FILE not found"
    exit 1
fi

# Replace the import line in style.css
sed -i "1s/@import \".*\.css\";/@import \"${THEME}.css\";/" "$CSS_FILE"

echo "Theme switched to: $THEME"

killall -SIGUSR2 waybar
