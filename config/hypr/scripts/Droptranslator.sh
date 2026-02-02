#!/bin/bash

CLASS="chrome-translate.google.com__-Profile_3"
COMMAND="chromium --app='https://translate.google.com/?sl=en&tl=ru&op=translate' --app-id='translator'"
SPECIAL_NAME="SP"

WINDOW_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | .address")

if [ -z "$WINDOW_ADDR" ]; then
    hyprctl dispatch exec "$COMMAND"
else
    IS_SPECIAL=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$WINDOW_ADDR\") | .workspace.name" | grep "special:$SPECIAL_NAME")

    if [ -z "$IS_SPECIAL" ]; then
        hyprctl dispatch pin address:$WINDOW_ADDR
        hyprctl dispatch movetoworkspacesilent "special:$SPECIAL_NAME,address:$WINDOW_ADDR"
    else
        hyprctl dispatch movetoworkspacesilent "1,address:$WINDOW_ADDR"
        hyprctl dispatch pin address:$WINDOW_ADDR
    fi
fi
