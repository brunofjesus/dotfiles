#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Call audio_changer.py from the same directory
"$SCRIPT_DIR/audio_changer.py" "$@"

