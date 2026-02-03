#!/bin/bash

YELLOW='\033[1;33m'
NC='\033[0m'

if command -v yay &> /dev/null; then
    echo -e "${YELLOW}✅ yay is already installed, skipping...${NC}"
    exit 0
fi

echo -e "${YELLOW}📦 Installing yay (AUR helper)...${NC}"

sudo pacman -S --needed --noconfirm base-devel git

TEMP_DIR=$(mktemp -d)
git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"
cd "$TEMP_DIR" || exit

makepkg -si --noconfirm

cd - > /dev/null
rm -rf "$TEMP_DIR"

echo -e "${YELLOW}✅ yay successfully installed!${NC}"