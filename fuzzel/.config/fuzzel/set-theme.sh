#!/bin/bash

# Fuzzel Theme Toggle Script
# Toggles between Frappe (dark) and Latte (light) themes

FUZZEL_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_FILE="$FUZZEL_DIR/theme.ini"
FRAPPE_FILE="$FUZZEL_DIR/frappe.ini"
LATTE_FILE="$FUZZEL_DIR/latte.ini"

set_theme() {
    local theme="$1"
    case "$theme" in
        "frappe")
            ln -sf "$FRAPPE_FILE" "$THEME_FILE"
            ;;
        "latte")
            ln -sf "$LATTE_FILE" "$THEME_FILE"
            ;;
        *)
            echo "❌ Invalid theme: $theme"
            echo "Available themes: frappe, latte"
            exit 1
            ;;
    esac
}

set_theme "$1"
