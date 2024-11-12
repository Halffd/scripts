#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <brightness_value>"
    exit 1
fi

# Assign parameters to variables
BRIGHTNESS_VALUE=$1

# Check if brightness value is a valid number
if ! [[ "$BRIGHTNESS_VALUE" =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]; then
    echo "Error: Brightness value must be a number, optionally starting with + or -."
    exit 1
fi

# Detect connected monitors
CONNECTED_MONITORS=$(xrandr | grep " connected" | awk '{ print $1 }')

# Set brightness for each connected monitor
for MONITOR in $CONNECTED_MONITORS; do
    # Get current brightness
    CURRENT_BRIGHTNESS=$(xrandr --verbose | grep -A 10 "$MONITOR" | grep "Brightness" | awk '{print $2}')
    
    # Calculate new brightness
    if [[ "$BRIGHTNESS_VALUE" == +* ]]; then
        NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS + ${BRIGHTNESS_VALUE:1}" | bc)
    elif [[ "$BRIGHTNESS_VALUE" == -* ]]; then
        NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS - ${BRIGHTNESS_VALUE:1}" | bc)
    else
        NEW_BRIGHTNESS="$BRIGHTNESS_VALUE"
    fi

    # Ensure new brightness is within the valid range [0.0, 1.0]
    if (( $(echo "$NEW_BRIGHTNESS < 0.0" | bc -l) )); then
        NEW_BRIGHTNESS=0.0
    elif (( $(echo "$NEW_BRIGHTNESS > 1.0" | bc -l) )); then
        NEW_BRIGHTNESS=1.0
    fi

    # Set the new brightness
    xrandr --output "$MONITOR" --brightness "$NEW_BRIGHTNESS"
    echo "Brightness set to $NEW_BRIGHTNESS for $MONITOR."
done
