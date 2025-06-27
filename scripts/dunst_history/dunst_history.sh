#!/bin/bash

# Get last 5 notifications from dunst history
# The format of dunstctl history is: <appname>\t<summary>\t<body>
dunstctl history | tail -n 5 | while IFS=$'\t' read -r app summary body; do
    # Send notification again via notify-send
    notify-send "$summary" "$body" -a "$app"
    sleep 0.1  # slight delay between notifications to avoid clumping
done
