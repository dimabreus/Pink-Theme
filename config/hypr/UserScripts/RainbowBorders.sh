#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for rainbow borders animation

function random_hex() {
    echo $(python ~/.config/hypr/UserScripts/Gradient.py)
}

# rainbow colors only for active window
hyprctl keyword general:col.active_border $(random_hex)  $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex)  270deg

# rainbow colors for inactive window (uncomment to take effect)
#hyprctl keyword general:col.inactive_border $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) 270deg