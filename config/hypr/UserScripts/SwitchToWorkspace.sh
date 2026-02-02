if [[ "$1" == "-99" ]]; then
    hyprctl dispatch togglespecialworkspace S-1
elif [[ "$1" == "-97" ]]; then
    hyprctl dispatch togglespecialworkspace S-2
else
    hyprctl dispatch workspace $1
fi