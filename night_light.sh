#!/bin/bash

# Enable night light
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Function to convert percentage to temperature
percent_to_temperature() {
    local percent=$1
    # Convert percentage to temperature (0% = 4700, 100% = 1700)
    echo $(( 4700 - (percent * 30) ))
}

# Check if an argument is provided
if [ "$#" -eq 1 ]; then
    input="$1"

    # Check if the input ends with '%' and is a valid number
    if [[ $input =~ ^[0-9]+%$ ]]; then
        # Extract the numeric part
        percent=${input%\%}
        # Convert to temperature and set it
        temperature=$(percent_to_temperature "$percent")
        gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature "$temperature"
    elif [[ $input =~ ^[0-9]+$ ]]; then
        # If it's a plain number, set it directly
        gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature "$input"
    else
        echo "Invalid input. Please provide a temperature (1700-4700) or a percentage (e.g., 50%)."
    fi
fi
