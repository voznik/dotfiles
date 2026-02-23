#!/bin/bash

# --- Configuration ---
TMP_MP4="/tmp/gsr_recording.mp4"
TMP_PALETTE="/tmp/gsr_palette.png"
TMP_UNOPTIMIZED="/tmp/gsr_unoptimized.gif"
PID_FILE="/tmp/gsr.pid"
LOG="/tmp/gsr.log"

GIF_DIR="$HOME/Videos"
FILENAME="$GIF_DIR/$(date +'%Y-%m-%d_%H-%M-%S').gif"

mkdir -p "$GIF_DIR"
# Overwrite log each time to keep it clean and relevant
echo "--- Triggered: $(date) ($1) ---" > "$LOG"

# --- Functions ---

is_recorder_running() {
    [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null
}

notify() {
    notify-send "$1" "$2" -t 3000
}

terminate_recording() {
    GSR_PID=$(cat "$PID_FILE")
    echo "Stopping recorder (PID $GSR_PID)..." >> "$LOG"
    kill -SIGINT "$GSR_PID"
    rm "$PID_FILE"
    
    # Revert UI: Using specific values to avoid 'Error parsing gradient'
    # Change 0xff444444 to your usual color and 2 to your usual thickness
    hyprctl --batch "keyword general:col.active_border 0xff444444 ; keyword general:border_size 2" >> "$LOG" 2>&1
    
    convert_and_optimize
}

convert_and_optimize() {
    notify "Processing..." "Optimizing colors and file size"
    
    echo "[1/3] Generating palette..." >> "$LOG"
    # Added format=rgb24 to ensure sRGB compatibility
    ffmpeg -y -i "$TMP_MP4" -vf "format=rgb24,palettegen=stats_mode=diff" "$TMP_PALETTE" >> "$LOG" 2>&1
    
    if [ ! -f "$TMP_PALETTE" ]; then
        echo "ERROR: Palette generation failed." >> "$LOG"
        notify "Error" "Palette generation failed."
        return 1
    fi

    echo "[2/3] Converting to raw GIF..." >> "$LOG"
    # Using Lanczos for sharp scaling, real-time speed
    ffmpeg -y -i "$TMP_MP4" -i "$TMP_PALETTE" -filter_complex "[0:v] fps=12,scale='min(iw,1400)':-1:flags=lanczos [new];[new][1:v] paletteuse=dither=sierra2_4a" "$TMP_UNOPTIMIZED" >> "$LOG" 2>&1
    
    echo "[3/3] Optimizing with Gifsicle..." >> "$LOG"
    if command -v gifsicle &> /dev/null; then
        # -O2 is the best balance of speed and compression
        gifsicle -O2 --lossy=80 "$TMP_UNOPTIMIZED" -o "$FILENAME" >> "$LOG" 2>&1
    else
        echo "WARN: Gifsicle not found, skipping optimization." >> "$LOG"
        mv "$TMP_UNOPTIMIZED" "$FILENAME"
    fi
    
    rm -f "$TMP_MP4" "$TMP_PALETTE" "$TMP_UNOPTIMIZED"
    notify "Recording Saved" "$(basename "$FILENAME")"
    echo "SUCCESS: Saved to $FILENAME" >> "$LOG"
}

start_recording() {
    local raw_geom=$1
    # Format slurp output to WxH+X+Y for GSR
    local gsr_geom=$(echo "$raw_geom" | sed 's/\([0-9]*\),\([0-9]*\) \([0-9]*x[0-9]*\)/\3+\1+\2/')
    
    echo "GSR Formatted Geometry: $gsr_geom" >> "$LOG"
    
    # Updated to use the new -w region syntax to avoid warnings
    gpu-screen-recorder -w "$gsr_geom" -f 30 -o "$TMP_MP4" >> "$LOG" 2>&1 &
    GSR_PID=$!
    echo "$GSR_PID" > "$PID_FILE"

    hyprctl --batch "keyword general:col.active_border rgb(ff0000) ; keyword general:border_size 4" >> "$LOG" 2>&1
    notify "Recording" "Capturing selected area..."

    (
        sleep 30
        if is_recorder_running; then
            $0 stop
        fi
    ) &
}

# --- Main Logic ---

if is_recorder_running; then
    terminate_recording
else
    case "$1" in
        area)
            GEOM=$(slurp)
            [ -n "$GEOM" ] && start_recording "$GEOM"
            ;;
        window)
            GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            [ -n "$GEOM" ] && [ "$GEOM" != "null,null nullxnull" ] && start_recording "$GEOM"
            ;;
        stop)
            # Handled by the toggle logic
            ;;
        *)
            echo "Usage: $0 {area|window|stop}"
            exit 1
            ;;
    esac
fi
