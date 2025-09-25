#!/bin/bash

# Temp files
SOCKET="/tmp/mpv-yt-socket"
PIDFILE="/tmp/mpv-yt.pid"

# Function to check if mpv is actually running
is_mpv_running() {
    echo "mpv check"
    if [ -f "$PIDFILE" ]; then
        local pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "mpv is running (PID: $pid)"
            return 0
        else
            echo "stale PID file, cleaning up"
            rm -f "$PIDFILE" "$SOCKET"
            return 1
        fi
    fi
    echo "mpv not running"
    return 1
}

# Function to start mpv if not running
start_mpv() {
    if ! is_mpv_running; then
      rm -f "$SOCKET"
      echo "Starting mpv..."
      mpv --force-window --idle=yes --input-ipc-server="$SOCKET" \
         --ytdl-format="bestvideo[height<=1080]+bestaudio/best[height<=1080]" &
 
      local mpv_pid=$!
      echo "$mpv_pid" > "$PIDFILE"
      echo "mpv started with PID: $mpv_pid"
      # Wait a moment for mpv to start
      sleep 1
    else
      echo "mpv is already running"
    fi
}

# Function to play video in existing mpv instance
play_video() {
    echo "sending loadfile command"
    local url="$1"
    printf '{ "command": ["loadfile", "%s"] }\n' "$url" | timeout 2 nc -U "$SOCKET"
}

# Ask for URL with clipboard content as default
if [ -n "$1" ]; then
    URL="$1"
else
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
fi

# Check if URL is empty
if [ -z "$URL" ]; then
    zenity --error \
        --text="URL cannot be empty" \
        --width=200
    exit 1
fi


# Start mpv if not already running
start_mpv

play_video "$URL"

exit 0
