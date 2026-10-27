#!/bin/sh

RUNNER="fuzzel -i --dmenu"
if tty -s; then
    RUNNER="fzf"
fi

PAIRED=`bluetoothctl devices Paired | grep Device | sed 's/Device //'`
CONNECTED=`bluetoothctl devices Connected | grep Device | sed 's/Device //'`

# Create a new list with X/O indicators
STATUS_LIST=""
while IFS= read -r device; do
    mac_addr=$(echo "$device" | awk '{print $1}')
    name=$(echo "$device" | cut -d' ' -f2-)
    
    if echo "$CONNECTED" | grep -q "$mac_addr"; then
        STATUS_LIST="${STATUS_LIST}🟢 $device\n"
    else
        STATUS_LIST="${STATUS_LIST}⚪ $device\n"
    fi
done <<< "$PAIRED"

# Remove trailing newline
STATUS_LIST=$(echo -e "$STATUS_LIST" | sed '$ s/\\n$//')


CHOICE=$(echo -e "$STATUS_LIST" | $RUNNER --prompt "Toggle connection: ") || exit 0

# Extract MAC address and connection status
MAC_ADDRESS=$(echo "$CHOICE" | awk '{print $2}')
STATUS_EMOJI=$(echo "$CHOICE" | awk '{print $1}')

# Toggle connection based on current status
if [ "$STATUS_EMOJI" = "🟢" ]; then
    # Device is connected, disconnect it
    DEVICE_NAME=$(echo "$CHOICE" | sed 's/🟢 [^ ]* //')
    if bluetoothctl disconnect "$MAC_ADDRESS" >/dev/null 2>&1; then
        notify-send -u normal "⚪ Bluetooth" "$DEVICE_NAME disconnected"
    else
        notify-send -u normal "❌ Bluetooth" "Failed to disconnect $DEVICE_NAME"
    fi
else
    # Device is disconnected, connect to it
    DEVICE_NAME=$(echo "$CHOICE" | sed 's/⚪ [^ ]* //')
    if bluetoothctl connect "$MAC_ADDRESS" >/dev/null 2>&1; then
        notify-send -u normal "🟢 Bluetooth" "$DEVICE_NAME connected"
    else
        notify-send -u normal "❌ Bluetooth" "Failed to connect to $DEVICE_NAME"
    fi
fi
