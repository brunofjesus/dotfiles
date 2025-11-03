#!/bin/bash

NEWSBOAT_DIR="$(dirname "$0")"
STYLE_FILE="$NEWSBOAT_DIR/style"
LATTE_FILE="$NEWSBOAT_DIR/latte"
FRAPPE_FILE="$NEWSBOAT_DIR/frappe"

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
  esac
}

set_theme "$1"
