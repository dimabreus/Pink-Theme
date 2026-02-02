#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager. This script uses cliphist, rofi, and wl-copy.

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg='👀 **note**  CTRL DEL = cliphist del (entry)   or   ALT DEL - cliphist wipe (all)'
# Actions:
# CTRL Del to delete an entry
# ALT Del to wipe clipboard contents

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

get_clip_list() {
    cliphist list | while read -r line; do
        id=$(echo "$line" | cut -f1)
        content=$(echo "$line" | cut -f2-)
        
        # Check if the content indicates an image
        if [[ "$content" == "[[ binary data"* ]]; then
            echo -en ""
        else
            # Send text entry normally
            echo -en "$line\n"
        fi
    done
}

while true; do
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
        1)
            exit
            ;;
        0)
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
            cliphist delete <<<"$result"
            ;;
        11)
            cliphist wipe
            ;;
    esac
done

