#!/bin/bash

# --- Configuration ---
# List of window classes that should be minimized instead of killed.
# Add any application that needs to be hidden to the tray icon here.
MINIMIZE_LIST=("Enpass" "Steam" "Discord") 
# NOTE: Replace "Enpass" with the actual class you found if it's different.

# --- Logic ---

# 1. Get the class and address (ID) of the currently active window using jq
ACTIVE_WINDOW_INFO=$(hyprctl activewindow -j)
ACTIVE_CLASS=$(echo "$ACTIVE_WINDOW_INFO" | jq -r ".class")
ACTIVE_ADDRESS=$(echo "$ACTIVE_WINDOW_INFO" | jq -r ".address")

# Flag to check if the window should be minimized
SHOULD_MINIMIZE=0

# Check if the active class is in the MINIMIZE_LIST
for TARGET_CLASS in "${MINIMIZE_LIST[@]}"; do
    if [ "$ACTIVE_CLASS" = "$TARGET_CLASS" ]; then
        SHOULD_MINIMIZE=1
        break # Exit the loop once a match is found
    fi
done

if [ $SHOULD_MINIMIZE -eq 1 ]; then
    # If it should be minimized, get the window ID (strip 0x for xdotool)
    # Note: xdotool needs the ID, so we get it from Hyprland's output.
    XID=${ACTIVE_ADDRESS:2}

    # Use xdotool to "unmap" (minimize/hide) the window
    xdotool windowunmap 0x$XID
else
    # Otherwise, kill the window normally
    hyprctl dispatch killactive ""
fi
