#!/bin/bash

FZF_DIR="$(dirname "$0")"
RC_FILE="$FZF_DIR/fzfrc"
LATTE_FILE="$FZF_DIR/latte"
FRAPPE_FILE="$FZF_DIR/frappe"

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
