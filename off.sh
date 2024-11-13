#!/bin/bash

# Prompt the user for an hour input
read -p "Enter the number of hours to schedule shutdown (0 for immediate shutdown): " hours

# Check if the user entered 0 for immediate shutdown
if [ "$hours" -eq 0 ]; then
    echo "Shutting down immediately..."
    sudo shutdown now
else
    # Calculate the time in minutes to schedule the shutdown
    shutdown_time=$((hours * 60))
    echo "Scheduling shutdown in $hours hour(s)..."
    sudo shutdown +$shutdown_time
fi

