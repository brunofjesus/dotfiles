#!/bin/sh

# Script to open URLs - YouTube links in mpv, other links in Brave
# Usage: ./url_opener.sh [URL]

URL="$1"

# Check if a URL was provided
if [ -z "$URL" ]; then
    echo "Error: No URL provided"
    echo "Usage: $0 [URL]"
    exit 1
fi

## Check if the URL's domain is youtube.com
#if echo "$URL" | grep -E "https?://(www\.)?youtube\.com(/.*)?"; then
#    echo "Opening YouTube URL with mpv..."
#    mpv "$URL"
#else
#    echo "Opening URL with Brave browser..."
#    brave "$URL"
#fi

brave "$URL"
