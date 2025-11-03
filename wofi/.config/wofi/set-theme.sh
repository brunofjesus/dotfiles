#!/bin/bash

# Wofi Theme Toggle Script
# Toggles between Frappe (dark) and Latte (light) themes

WOFI_DIR="$(dirname "$0")"
STYLE_FILE="$WOFI_DIR/style.css"
FRAPPE_FILE="$WOFI_DIR/style-frappe.css"
LATTE_FILE="$WOFI_DIR/style-latte.css"


# Function to set theme
set_theme() {
    local theme="$1"
    case "$theme" in
        "frappe")
            cp "$FRAPPE_FILE" "$STYLE_FILE"
            ;;
        "latte")
            cp "$LATTE_FILE" "$STYLE_FILE"
            ;;
        *)
            echo "❌ Invalid theme: $theme"
            echo "Available themes: frappe, latte"
            exit 1
            ;;
    esac
}

set_theme "$1"

