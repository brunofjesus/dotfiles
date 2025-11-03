#!/bin/bash

ZATHURA_CONFIG="$HOME/.config/zathura/zathurarc"

sed -i "1s/.*/include catppuccin-$1/" "$ZATHURA_CONFIG"
