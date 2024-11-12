#!/bin/bash

# Check if a URL is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

# Assign the first argument to the URL variable
URL=$1

# Run streamlink in the background and redirect output to /dev/null
(streamlink --player="mpv" $URL best > /dev/null 2>&1 &) 

# Exit the script
exit 0
