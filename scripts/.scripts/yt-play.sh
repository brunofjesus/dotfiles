#!/bin/bash

# Ask for URL with clipboard content as default
URL=$(zenity --entry \
    --title="YouTube Player" \
    --text="Enter video URL:" \
    --entry-text="$(wl-paste)" \
    --width=800)

# Check if user clicked cancel
if [ $? -ne 0 ]; then
    echo "Playback cancelled"
    exit 1
fi

# Check if URL is empty
if [ -z "$URL" ]; then
    zenity --error \
        --text="URL cannot be empty" \
        --width=200
    exit 1
fi

# Play the video
mpv --ytdl-format="bestvideo[height<=?800][fps<=?30][vcodec!=?vp9]+bestaudio/best" "$URL"

