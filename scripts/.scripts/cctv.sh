#!/bin/bash

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
else
  source ~/.env
fi

OPTIONS="🛋️ Sala\n🧑‍🍳 Cozinha\n🚘 Garagem\n🚪 Entrada"

CHOICE=$(echo -e "$OPTIONS" | $RUNNER --prompt "Camera: " | awk '{print tolower($2)}' )


case "$CHOICE" in
    "sala")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.90/Streaming/Channels/101
        ;;
    "cozinha")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.91/Streaming/Channels/101
        ;;

    "garagem")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.92/Streaming/Channels/101
        ;;
    "entrada")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.93/Streaming/Channels/101
        ;;
esac
