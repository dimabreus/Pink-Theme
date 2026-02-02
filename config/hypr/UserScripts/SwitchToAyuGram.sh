#!/bin/bash

id=$(hyprctl clients -j | jq -r '.[] | select((.class//""|ascii_downcase) | contains("ayugram")) | "\(.workspace.id)"')

if [[ $id == "" ]]; then
    AyuGram
else
    bash $HOME/.config/hypr/UserScripts/SwitchToWorkspace.sh $id
fi
