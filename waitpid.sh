#!/bin/bash

# Start a background process (for example, sleep for 5 seconds)
sleep 5 &

# Get the PID of the background process
pid=$!

# Optionally, you can specify options (e.g., WNOHANG)
options=0  # Change this if you want to use specific options

# Wait for the process to finish and get the exit status
wait $pid
statloc=$?

# Output the PID and the exit status
echo "Process ID: $pid"
echo "Exit Status: $statloc"