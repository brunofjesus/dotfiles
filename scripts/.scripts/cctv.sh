#!/bin/bash

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
else
  source ~/.env
fi

declare -A camera_map
camera_map["sala"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.90/Streaming/Channels/101";
camera_map["cozinha"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.91/Streaming/Channels/101";
camera_map["garagem"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.92/Streaming/Channels/101";
camera_map["entrada"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.93/Streaming/Channels/101";

OPTIONS="🛋️ Sala\n🧑‍🍳 Cozinha\n🚘 Garagem\n🚪 Entrada\n🔳 Grid"

CHOICE=$(echo -e "$OPTIONS" | $RUNNER --prompt "Camera: " | awk '{print tolower($2)}' )


case "$CHOICE" in
    "sala"|"cozinha"|"garagem"|"entrada")
      mpv ${camera_map[$CHOICE]}
      ;;
    "grid")
      swaymsg "exec mpv ${camera_map[sala]}; exec mpv ${camera_map[cozinha]}" && sleep 3 && swaymsg "splitt" && swaymsg "exec mpv ${camera_map[garagem]}" && sleep 3 && swaymsg "focus left; focus up; splitt" && swaymsg "exec mpv ${camera_map[entrada]}"
      ;;
esac
