#!/bin/sh

URL=$1
TITLE=$(echo $URL| cut -d'/' -f 8)

if [ $# = 2 ]
then
    if [ -d $2 ]
    then
        if [ ${2: -1} = "/" ]
        then
            OUTPUT="${2}${TITLE}"
        else
            OUTPUT="${2}/${TITLE}"
        fi
    else
        OUTPUT="${2%.*}"
    fi
elif [ $# = 1 ]
then
    OUTPUT=$TITLE
fi

ffmpeg -i $(wget -qO- "https://api.reddit.com/api/info/?id=t3_$(echo $URL| cut -d'/' -f 7)" | jq -r '.data.children[0].data.secure_media.reddit_video.dash_url') -c copy "${OUTPUT}.mp4"
