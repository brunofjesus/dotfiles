#!/bin/bash

DIR="$(dirname "$0")"
CONFIG_FILE="$DIR/config.yml"
LATTE_FILE="$DIR/config-latte.yml"
FRAPPE_FILE="$DIR/config-frappe.yml"

set_theme() {
    local theme="$1"
    case "$theme" in
        latte)
            cp "$LATTE_FILE" "$CONFIG_FILE"
            ;;
        frappe)
            cp "$FRAPPE_FILE" "$CONFIG_FILE"
            ;;
        *)
            echo "Unknown theme: $theme"
            echo "Available themes: latte, frappe"
            return 1
            ;;
    esac
}

set_theme "$1"
