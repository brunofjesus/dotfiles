#!/bin/bash

# This script is used to enable the internal display when no external display is connected
# It's aimed to be ran as a systemd service when the system wakes up from sleep

# systemctl --user daemon-reload
# systemctl --user enable display-wakeup.service
#
# Check connected outputs
LID_STATE_FILE="/proc/acpi/button/lid/LID0/state"
INTERNAL_DISPLAY="eDP-1"

# Check if lid state file exists
if [ ! -f "$LID_STATE_FILE" ]; then
    echo "Lid state file not found."
    exit 1
fi

lid_state=$(cat "$LID_STATE_FILE" | awk '{print $2}')

# If lid is open and no other display is connected, turn on the internal display
if [ "$lid_state" = "open" ]; then
    connected_outputs=$(wlr-randr --json | jq -r '.[] | select(.enabled) | .name')
    echo "Connected outputs: $connected_outputs"
    
    # Check if any external display is connected
    external_connected=$(echo "$connected_outputs" | grep -v "$INTERNAL_DISPLAY")
    echo "External displays connected: $external_connected"
    
    if [ -z "$external_connected" ]; then
        echo "No external displays connected"
        # No external displays, enable the internal display
        wlr-randr --output "$INTERNAL_DISPLAY" --on
        echo "Internal display $INTERNAL_DISPLAY enabled"
    fi
fi


