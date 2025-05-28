#!/bin/bash

TEMP_FILE=$(mktemp)
MAPPING_FILE=$(mktemp)

# Download the M3U playlist
curl -s -o "$TEMP_FILE" https://raw.githubusercontent.com/LITUATUI/M3UPT/main/M3U/M3UPT.m3u

# Function to run commands in terminal or kitty
command_runner() {
   eval "$1"
}

# Parse the M3U file to extract channel names and URLs
parse_channels() {
    local file="$1"
    local mapping_file="$2"
    local channels=""
    local current_channel=""
    local current_url=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^#EXTINF:.+,(.+)$ ]]; then
            # Extract channel name
            current_channel="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^https?:// ]]; then
            # This is a URL line
            current_url="$line"
            # Add channel to the list if both name and URL are available
            if [[ -n "$current_channel" && -n "$current_url" ]]; then
                if [[ -n "$channels" ]]; then
                    channels="$channels\n$current_channel"
                else
                    channels="$current_channel"
                fi

                # Store mapping in the mapping file
                echo "$current_channel::$current_url" >> "$mapping_file"
                # Reset for next channel
                current_channel=""
                current_url=""
            fi
        fi
    done < "$file"
    
    echo -e "$channels"
}

RUNNER="wofi -i --dmenu"

# Parse channels and display menu
CHANNELS=$(parse_channels "$TEMP_FILE" "$MAPPING_FILE")
CHOICE=$(echo -e "$CHANNELS" | $RUNNER --prompt "Select IPTV Channel")

# Exit if no selection was made
if [[ -z "$CHOICE" ]]; then
    echo "No channel selected, exiting..."
    rm "$TEMP_FILE"
    rm "$MAPPING_FILE"
    exit 0
fi

# Get the URL for the selected channel from the mapping file
SELECTED_URL=$(grep "^$CHOICE::" "$MAPPING_FILE" | cut -d':' -f3-)

# We need ytdl for RTP streams
if [[ "$SELECTED_URL" =~ streaming-live\.rtp\.pt ]]; then
    # Replace https with ytdl for RTP streams
    SELECTED_URL=$(echo "$SELECTED_URL" | sed 's|https://|ytdl://|')
fi

if [[ -n "$SELECTED_URL" ]]; then
    # Play the selected channel with mpv
    command_runner "mpv --profile=low-latency \"$SELECTED_URL\""
else
    echo "Error: Could not find URL for selected channel"
fi

# Clean up
rm "$TEMP_FILE"
rm "$MAPPING_FILE"

