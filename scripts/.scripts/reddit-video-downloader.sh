#!/bin/sh

# Get URL from command line or zenity
if [ $# -ge 1 ]; then
    URL=$1
else
    URL=$(zenity --entry \
        --entry-text="$(wl-paste)" \
        --title="Reddit Video Downloader" \
        --text="Enter the Reddit video URL:" \
        --width=800)
    
    # Check if user clicked cancel
    if [ $? -ne 0 ]; then
        echo "Download cancelled"
        exit 1
    fi
    
    # Check if URL is empty
    if [ -z "$URL" ]; then
        zenity --error \
            --text="URL cannot be empty" \
            --width=200
        exit 1
    fi
fi

TITLE=$(echo $URL| cut -d'/' -f 8)

ffmpeg -i $(wget -qO- "https://api.reddit.com/api/info/?id=t3_$(echo $URL| cut -d'/' -f 7)" | jq -r '.data.children[0].data.secure_media.reddit_video.dash_url') -c copy "$HOME/Videos/${TITLE}.mp4"
