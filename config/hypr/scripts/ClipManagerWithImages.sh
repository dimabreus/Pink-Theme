#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager with Image Previews.

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboardWithImages.rasi"
msg='👀 **note**  CTRL DEL = cliphist del (entry)   or   ALT DEL - clear cache'
cache_dir="/tmp/cliphist_thumbs"

# Create cache dir if not exists
mkdir -p "$cache_dir"

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Function to generate list with icons
get_clip_list() {
    cliphist list | while read -r line; do
        id=$(echo "$line" | cut -f1)
        content=$(echo "$line" | cut -f2-)
        
        # Check if the content indicates an image
        if [[ "$content" == "[[ binary data"* ]]; then
            # Define image path based on ID
            img_path="$cache_dir/$id.png"
            
            # Decode only if file doesn't exist (caching)
            if [ ! -f "$img_path" ]; then
                cliphist decode "$id" > "$img_path"
            fi

            # Send to Rofi with icon escape sequence
            echo -en "$id\0icon\x1f$img_path\n"
        else
            # Send text entry normally
            echo -en ""
        fi
    done
}

while true; do
    # Added -show-icons and calling the function instead of direct cliphist list
    result=$(
        get_clip_list | rofi -dmenu \
            -i \
            -show-icons \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -config "$rofi_theme" \
            -mesg "$msg" 
    )

    exit_code=$?

    case "$exit_code" in
        1) # Escape/Cancel
            exit
            ;;
        0) # Enter selected
            case "$result" in
                "")
                    continue
                    ;;
                *)
                    id=$(echo "$result" | cut -f1)

                    cliphist decode "$id" | wl-copy
                    exit
                    ;;
            esac
            ;;
        10)
            cliphist delete <<<"${result}"
            notify-send -e -r 1 -u low "DELETED from clip manager:${result}"
            ;;
        11)
            rm -rf "$cache_dir"/*
            ;;
    esac
done