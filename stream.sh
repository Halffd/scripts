#!/bin/bash

# Check if a URL is provided
if [ "$#" -ne 1 ]; then
    URL=$(xclip -o)
else
    URL="$1"
fi

# Run streamlink in the background and redirect output to /dev/null
nohup streamlink --player="mpv" $URL best > /dev/null 2>&1 &

# Exit the script
exit 0
