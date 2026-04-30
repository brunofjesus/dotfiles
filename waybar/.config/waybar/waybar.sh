#!/bin/sh

# Abort if another instance of this script is running
script_name=$(basename "$0")
if [ "$(pgrep -c -x "$script_name")" -gt 1 ]; then
  exit 1
fi

# Abort if waybar is already running
if pgrep -x waybar > /dev/null; then
  exit 1
fi

while true; do
  echo "Starting waybar" >> /tmp/waybar.log
  waybar >> /tmp/waybar.log
  echo "Waybar crashed" >> /tmp/waybar.log
done
