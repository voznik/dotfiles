#!/bin/bash

# --- 1. Get monitor info in one step ---
# Use jq to output the monitor name and transform value separated by newlines.
# Use process substitution (<(...)) with IFS set to newline to assign directly into the two variables in one command.
IFS=$'\n' read -r focused_monitor current_transform < <(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name, .transform')

# --- 2. Check for monitor ---
if [ -z "$focused_monitor" ]; then
    echo "Error: Could not find focused monitor." >&2
    exit 1
fi

# --- 3. Disable the focused monitor ---
# This forces all content (workspaces/windows) to move to the next active monitor.
hyprctl keyword monitor "$focused_monitor, disable"

# --- 4. Re-enable the monitor with dynamic settings ---
# Use 'preferred' for resolution/rate, 'auto' for position, and restore the rotation.
sleep 0.5
hyprctl keyword monitor "$focused_monitor, preferred, auto, 1, transform, $current_transform"
