#!/bin/bash

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
fi

# List icon themes
ICON_THEMES=$(find /usr/share/icons/ ~/.icons/ -maxdepth 1 -type d | awk -F/ '{print $NF}' | sort | uniq)

# Use `fzf` for interactive selection (or `wofi`/`rofi` if desired)
SELECTED_ICON_THEME=$(echo "$ICON_THEMES" | $RUNNER --prompt="Select an icon theme: ")

if [ -n "$SELECTED_ICON_THEME" ]; then
  echo "Applying icon theme: $SELECTED_ICON_THEME"
  gsettings set org.gnome.desktop.interface icon-theme "$SELECTED_ICON_THEME"
else
  echo "No icon theme selected."
fi
