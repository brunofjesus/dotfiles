#!/bin/bash

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
else
  source ~/.env
fi

OPTIONS="Sala\nCozinha\nGaragem\nEntrada"

CHOICE=$(echo -e "$OPTIONS" | $RUNNER --prompt "Camera: ")


case "$CHOICE" in
    "Sala")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.90/Streaming/Channels/101
        ;;
    "Cozinha")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.91/Streaming/Channels/101
        ;;

    "Garagem")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.92/Streaming/Channels/101
        ;;
    "Entrada")
        mpv rtsp://admin:${CCTV_PASSWORD}@172.30.1.93/Streaming/Channels/101
        ;;
esac
