#!/bin/sh

# Check if required tools are installed
check_dependencies() {
    for cmd in ffmpeg wget jq yt-dlp; do
        if ! command -v $cmd >/dev/null 2>&1; then
            zenity --error \
                --text="Required tool not found: $cmd\nPlease install it first." \
                --width=200
            exit 1
        fi
    done
}

check_dependencies

# Get URL from command line or zenity
if [ $# -ge 1 ]; then
    URL=$1
else
    URL=$(zenity --entry \
        --entry-text="$(wl-paste)" \
        --title="Video Downloader" \
        --text="Enter the Reddit or YouTube video URL:" \
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

# Detect if URL is from YouTube or Reddit
if echo "$URL" | grep -q "reddit.com"; then
    echo "Detected Reddit URL"
    TITLE=$(echo $URL| cut -d'/' -f 8)
    kitty --class "floating_kitty" -e bash -c "echo 'Starting Reddit download...'; ffmpeg -i \$(wget -qO- 'https://api.reddit.com/api/info/?id=t3_$(echo $URL| cut -d'/' -f 7)' | jq -r '.data.children[0].data.secure_media.reddit_video.dash_url') -c copy '$HOME/Videos/${TITLE}.mp4'; echo 'Download complete! Press Enter to close...'; read"
elif echo "$URL" | grep -q "youtube\|youtu.be"; then
    echo "Detected YouTube URL"
    if tty -s; then
        yt-dlp -o '$HOME/Videos/%(title)s.%(ext)s' "$URL"
      else
        kitty --class "floating_kitty" -e bash -c "echo 'Starting YouTube download...'; yt-dlp -o '$HOME/Videos/%(title)s.%(ext)s' '$URL'; echo 'Download complete! Press Enter to close...'; read"
    fi

else
  echo "Falling back to yt-dlp"
  if tty -s; then
        yt-dlp -o '$HOME/Videos/%(title)s.%(ext)s' "$URL"
     else
        kitty --class "floating_kitty" -e bash -c "echo 'Starting YT-DLP download...'; yt-dlp -o '$HOME/Videos/%(title)s.%(ext)s' '$URL'; echo 'Download complete! Press Enter to close...'; read"
  fi
fi
