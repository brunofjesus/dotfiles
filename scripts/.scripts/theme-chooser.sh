#!/bin/bash

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
fi

# List themes
THEMES=$(ls /usr/share/themes/ ~/.themes/ 2>/dev/null | sort | uniq)

# Use `fzf` for interactive selection or `wofi`/`rofi` if you prefer
SELECTED_THEME=$(echo "$THEMES" | $RUNNER --prompt="Select a GTK theme: ")

if [ -n "$SELECTED_THEME" ]; then
  echo "Applying theme: $SELECTED_THEME"
  gsettings set org.gnome.desktop.interface gtk-theme "$SELECTED_THEME"
else
  echo "No theme selected."
fi
