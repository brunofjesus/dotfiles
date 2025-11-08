#!/bin/bash

LSD_DIR="$(dirname "$0")"
RC_FILE="$LSD_DIR/colors.yaml"
LATTE_FILE="$LSD_DIR/colors-latte.yaml"
FRAPPE_FILE="$LSD_DIR/colors-frappe.yaml"

set_theme() {
    local theme="$1"
    case "$theme" in
        latte)
            cp "$LATTE_FILE" "$RC_FILE"
            ;;
        frappe)
            cp "$FRAPPE_FILE" "$RC_FILE"
            ;;
        *)
            echo "Unknown theme: $theme"
            echo "Available themes: latte, frappe"
            return 1
            ;;
    esac
}

set_theme "$1"
