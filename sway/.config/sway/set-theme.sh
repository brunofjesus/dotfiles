#!/bin/bash

SWAY_CONFIG="$HOME/.config/sway/config"
THEME_DIR="$HOME/.config/sway"

case "$1" in
    "frappe")
        NEW_THEME="catppuccin-frappe"
        ;;
    "latte")
        NEW_THEME="catppuccin-latte"
        ;;
    "mocha")
        NEW_THEME="catppuccin-mocha"
        ;;
    *)
        NEW_THEME="catppuccin-frappe"
        ;;
esac

THEME_FILE="$THEME_DIR/$NEW_THEME"

# Replace the first line with the new theme
sed -i "1s/.*/include $NEW_THEME/" "$SWAY_CONFIG"

# Extract and source color variables from theme file
while IFS= read -r line; do
    # Extract variable name and value
    var_name=$(echo "$line" | sed 's/set \$\([^ ]*\) .*/\1/')
    var_value=$(echo "$line" | sed 's/set \$[^ ]* \(.*\)/\1/')
    # Export the variable
    export "$var_name"="$var_value"
done < <(grep "^set \\\$" "$THEME_FILE")


# Apply colors to existing windows without reload
swaymsg "client.focused $lavender $base $text $rosewater $lavender"
swaymsg "client.focused_inactive $overlay0 $base $text $rosewater $overlay0"
swaymsg "client.unfocused $overlay0 $mantle $overlay0 $rosewater $overlay0"
swaymsg "client.urgent $peach $base $peach $overlay0 $peach"
swaymsg "client.placeholder $overlay0 $base $text $overlay0 $overlay0"
swaymsg "client.background $base"

# Update wallpaper if specified in theme
WALLPAPER_LINE=$(grep "^output.*bg" "$THEME_FILE")
if [ -n "$WALLPAPER_LINE" ]; then
    # Extract and apply wallpaper command
    WALLPAPER_CMD=$(echo "$WALLPAPER_LINE" | sed 's/output //')
    swaymsg "output $WALLPAPER_CMD"
fi

