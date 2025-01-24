#!/usr/bin/env bash


RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
fi

# Define the options
OPTIONS="Select Area (Save)\nFull Screenshot (Save)\nSelect Area (Copy)\nFull Screenshot (Copy)\nSelect Area (Edit)"

# Show wofi menu and get user selection
CHOICE=$(echo -e "$OPTIONS" | $RUNNER --prompt "Screenshot")

# Get current date-time for filename
FILENAME="ps_$(date +"%Y%m%d%H%M%S").png"

# Execute the selected option
case "$CHOICE" in
    "Select Area (Save)")
        grim -g "$(slurp)" ~/"$FILENAME"
        ;;
    "Full Screenshot (Save)")
        grim ~/"$FILENAME"
        ;;
    "Select Area (Copy)")
        grim -g "$(slurp)" - | wl-copy
        ;;
    "Full Screenshot (Copy)")
        grim - | wl-copy
        ;;
    "Select Area (Edit)")
        grim -g "$(slurp)" - | swappy -f -
        ;;
esac


