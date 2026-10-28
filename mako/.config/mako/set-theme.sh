#!/bin/bash

# Mako Theme Toggle Script
# Toggles between Frappe (dark) and Latte (light) themes

MAKO_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_FILE="$MAKO_DIR/config"
FRAPPE_FILE="$MAKO_DIR/catppuccin-frappe"
LATTE_FILE="$MAKO_DIR/catppuccin-latte"

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

    makoctl reload
}

set_theme "$1"
