id=$(hyprctl clients -j | jq -r '.[] | select((.class//""|ascii_downcase) | contains("vesktop")) | "\(.workspace.id)"')

if [[ $id == "" ]]; then
    vesktop
else
    bash $HOME/.config/hypr/UserScripts/SwitchToWorkspace.sh $id
fi
