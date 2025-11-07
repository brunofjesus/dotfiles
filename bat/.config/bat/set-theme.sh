#!/bin/bash

BAT_DIR="$(dirname "$0")"
CONFIG_FILE="$BAT_DIR/config"

set_theme() {
    local theme="$1"
    case "$theme" in
        latte)
            echo "--theme=\"Catppuccin Latte\"" > $CONFIG_FILE
            ;;
        frappe)
            echo "--theme=\"Catppuccin Frappe\"" > $CONFIG_FILE
            ;;
        *)
            echo "Unknown theme: $theme"
            echo "Available themes: latte, frappe"
            return 1
            ;;
    esac
}

set_theme "$1"
