#!/bin/bash

# This script is used to enable the internal display when no external display is connected
# It's aimed to be ran as a systemd service when the system wakes up from sleep

# systemctl --user daemon-reload
# systemctl --user enable display-wakeup.service
#
# Check connected outputs
LID_STATE_FILE=$(ls /proc/acpi/button/lid/*/state 2>/dev/null | head -1)

# Check if lid state file exists
if [ -z "$LID_STATE_FILE" ] || [ ! -f "$LID_STATE_FILE" ]; then
    echo "Lid state file not found."
    exit 1
fi

lid_state=$(awk '{print $2}' "$LID_STATE_FILE")

# If lid is open, check display status
if [ "$lid_state" = "open" ]; then
    display_status=$(wlr-randr --json)

    # Auto-detect internal display (eDP or LVDS)
    INTERNAL_DISPLAY=$(echo "$display_status" | jq -r '.[].name' | grep -E '^(eDP|LVDS)-' | head -1)

    if [ -z "$INTERNAL_DISPLAY" ]; then
        echo "Internal display not found."
        exit 1
    fi

    # First check if internal display is enabled
    internal_enabled=$(echo "$display_status" | jq -r ".[] | select(.name == \"$INTERNAL_DISPLAY\" and .enabled)")
    
    if [ -z "$internal_enabled" ]; then
        # Check if any external display is connected and enabled
        external_connected=$(echo "$display_status" | jq -r ".[] | select(.name != \"$INTERNAL_DISPLAY\" and .enabled) | .name")
        
        if [ -z "$external_connected" ]; then
            echo "No displays enabled"
            # No displays enabled, turn on internal display
            wlr-randr --output "$INTERNAL_DISPLAY" --on
            echo "Internal display $INTERNAL_DISPLAY enabled"
        fi
    fi
fi


