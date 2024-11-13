#!/bin/bash

# Check if any arguments are provided
if [ "$#" -eq 0 ]; then
  # Reset brightness and color temperature for all connected monitors
  CONNECTED_MONITORS=$(xrandr | grep " connected" | awk '{ print $1 }')
  for MONITOR in $CONNECTED_MONITORS; do
    xrandr --output "$MONITOR" --brightness 1.0
    xrandr --output "$MONITOR" --gamma 1.0:1.0:1.0
    echo "Brightness and color temperature reset for $MONITOR."
  done
  exit 0
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 -a "$#" -ne 2 ]; then
    echo "Usage: $0 <brightness_value> [<color_temperature>]"
    exit 1
fi

# Assign parameters to variables
BRIGHTNESS_VALUE=$1
COLOR_TEMPERATURE=$2

# Check if brightness value is a valid number
if ! [[ "$BRIGHTNESS_VALUE" =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]; then
    echo "Error: Brightness value must be a number, optionally starting with + or -."
    exit 1
fi

# Check if color temperature is a valid number if provided
if [[ -n "$COLOR_TEMPERATURE" ]]; then
    if [[ "$COLOR_TEMPERATURE" =~ ^[0-9]+%$ ]]; then
        # If the color temperature ends with %, convert it to a float
        COLOR_TEMPERATURE=$(echo "$COLOR_TEMPERATURE" | sed 's/%//')  # Remove the '%' sign
        COLOR_TEMPERATURE=$(echo "scale=2; $COLOR_TEMPERATURE / 100" | bc)  # Convert to a float (e.g., 150% -> 1.50)
    elif ! [[ "$COLOR_TEMPERATURE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: Color temperature must be a number or a percentage (e.g., 150%)."
        exit 1
    fi
fi

# Map the percentage to a red gamma intensity
# The higher the value, the more red is applied
# Lower values (0% or 0K) => neutral (1.0:1.0:1.0)
# Higher values (100% or 6500K) => red dominance (higher R, lower G/B)

# Calculate gamma values based on the input color temperature percentage
if [[ -n "$COLOR_TEMPERATURE" ]]; then
    # Ensure the value is between 0.0 and 100.0
    if (( $(echo "$COLOR_TEMPERATURE < 0.0" | bc -l) )); then
        COLOR_TEMPERATURE=0.0
    elif (( $(echo "$COLOR_TEMPERATURE > 100.0" | bc -l) )); then
        COLOR_TEMPERATURE=100.0
    fi
    
    # Map 0% (or 0K) to neutral and 100% (or 6500K) to a strong red
    RED_INTENSITY=$(echo "scale=2; 1.0 + ($COLOR_TEMPERATURE / 100) * 1.0" | bc)
    GREEN_INTENSITY=$(echo "scale=2; 1.0 - ($COLOR_TEMPERATURE / 100) * 0.7" | bc)
    BLUE_INTENSITY=$(echo "scale=2; 1.0 - ($COLOR_TEMPERATURE / 100) * 0.7" | bc)
    
    # Ensure the green and blue channels do not go below 0.0
    if (( $(echo "$GREEN_INTENSITY < 0.0" | bc -l) )); then
        GREEN_INTENSITY=0.0
    fi
    if (( $(echo "$BLUE_INTENSITY < 0.0" | bc -l) )); then
        BLUE_INTENSITY=0.0
    fi
    
    GAMMA_VALUE="$RED_INTENSITY:$GREEN_INTENSITY:$BLUE_INTENSITY"
else
    # Default to neutral color (no red shift) if no color temperature is specified
    GAMMA_VALUE="1.0:1.0:1.0"
fi

# Detect connected monitors
CONNECTED_MONITORS=$(xrandr | grep " connected" | awk '{ print $1 }')

# Set brightness and color temperature for each connected monitor
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

    # Apply gamma (color temperature) and brightness settings to the monitor
    xrandr --output "$MONITOR" --brightness "$NEW_BRIGHTNESS" --gamma "$GAMMA_VALUE"
    echo "Gamma set to $GAMMA_VALUE and Brightness set to $NEW_BRIGHTNESS for $MONITOR."
done
