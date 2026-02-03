#!/bin/bash

BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_PATH="$HOME/config_backups/$BACKUP_NAME"

# Updated list of config directories
CONFIG_DIRS=(
    "cava" "fastfetch" "hypr" "kitty" "Kvantum" 
    "qt5ct" "qt6ct" "quickshell" "rofi" "waybar" 
    "vesktop" "yazi"
)

echo -e "${BLUE}📦 Starting backup process...${NC}"
mkdir -p "$BACKUP_PATH"

# Backup .config folders
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "💾 Copying $dir to $BACKUP_PATH"
        cp -r "$HOME/.config/$dir" "$BACKUP_PATH/"
    else
        echo "⏭️  Skipping: $dir (not found in ~/.config)"
    fi
done

# Backup .peaclock folder
if [ -d "$HOME/.peaclock" ]; then
    echo "💾 Copying .peaclock to $BACKUP_PATH"
    cp -r "$HOME/.peaclock" "$BACKUP_PATH/"
fi

# Backup .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$BACKUP_PATH/zshrc_backup"
    echo "💾 Copying .zshrc to $BACKUP_PATH"
fi

echo -e "${BLUE}✅ Backup complete! Files saved in: $BACKUP_PATH${NC}"