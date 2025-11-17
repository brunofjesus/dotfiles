#!/bin/sh
# Check if parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <theme>"
    echo "Available themes: latte, mocha, frappe, macchiato"
    exit 1
fi

THEME=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_FILE="$SCRIPT_DIR/btop.conf"
THEME_PATH="$SCRIPT_DIR/themes/catppuccin_${THEME}.theme"

# Validate theme parameter
if [[ "$THEME" != "latte" && "$THEME" != "mocha" && "$THEME" != "frappe" && "$THEME" != "macchiato" ]]; then
    echo "Error: Invalid theme '$THEME'"
    echo "Available themes: latte, mocha, frappe, macchiato"
    exit 1
fi

# Check if btop.conf exists
if [ ! -f "$CONF_FILE" ]; then
    echo "Error: $CONF_FILE not found"
    exit 1
fi

# Check if theme file exists
if [ ! -f "$THEME_PATH" ]; then
    echo "Error: Theme file $THEME_PATH not found"
    exit 1
fi

# Replace the color_theme line in btop.conf
sed -i "s|^color_theme = .*|color_theme = \"$THEME_PATH\"|" "$CONF_FILE"

echo "Theme switched to: $THEME"

