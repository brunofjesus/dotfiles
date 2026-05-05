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

for i in $(seq 1 10); do
  echo "Starting waybar" >> /tmp/waybar.log
  waybar -l debug >> /tmp/waybar.log
  echo "Waybar crashed" >> /tmp/waybar.log
done
