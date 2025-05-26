#!/bin/bash

command_runner() {
  if tty -s; then
    eval "$1"
  else
    kitty --class 'floating_kitty' -e bash -c "$1"
  fi
}

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
fi

OPTIONS="Record Area\nRecord Full Screen\nRecord Area (with Audio)\nRecord Full Screen (with Audio)\nRecord Area (with Microphone)\nRecord Full Screen (with Microphone)"


# Show wofi menu and get user selection
CHOICE=$(echo -e "$OPTIONS" | $RUNNER --prompt "Screen Recording")

# Get current date-time for filename
FILENAME="$HOME/Videos/recording_$(date +"%Y%m%d%H%M%S").mp4"

MICROPHONE="alsa_input.pci-0000_c1_00.6.analog-stereo"
OUTPUT="alsa_output.pci-0000_c1_00.6.analog-stereo.monitor"

case "$CHOICE" in
    "Record Area")
        GEOMETRY=$(slurp)
        command_runner "wf-recorder -c h264_vaapi -d /dev/dri/renderD128 -f \"$FILENAME\" -g \"$GEOMETRY\""
        ;;
    "Record Area (with Microphone)")
        GEOMETRY=$(slurp)
        command_runner "wf-recorder -c h264_vaapi -d /dev/dri/renderD128 --audio=\"$MICROPHONE\" -f \"$FILENAME\" -g \"$GEOMETRY\""
        ;;
    "Record Area (with Audio)")
        GEOMETRY=$(slurp)
        command_runner "wf-recorder -c h264_vaapi -d /dev/dri/renderD128 --audio=\"$OUTPUT\" -f \"$FILENAME\" -g \"$GEOMETRY\""
        ;;
    "Record Full Screen")
        command_runner "wf-recorder -c h264_vaapi -d /dev/dri/renderD128 -f \"$FILENAME\""
        ;;
    "Record Full Screen (with Microphone)")
        command_runner "wf-recorder -c h264_vaapi -d /dev/dri/renderD128 --audio=\"$MICROPHONE\" -f \"$FILENAME\""
        ;;
    "Record Full Screen (with Audio)")
        command_runner "wf-recorder -c h264_vaapi -d /dev/dri/renderD128 --audio=\"$OUTPUT\" -f \"$FILENAME\""
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
    esac
