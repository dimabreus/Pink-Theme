#!/bin/bash

copy-theme() {
    echo "🎨 Copying themes and settings..."

    mkdir -p ~/.oh-my-zsh/themes
    
    cp zsh/themes/* ~/.oh-my-zsh/themes/ 2>/dev/null
    cp zsh/zshrc ~/.zshrc
    cp zsh/RandomFastfetchIcon.sh ~/.oh-my-zsh/

    chmod +x ~/.oh-my-zsh/RandomFastfetchIcon.sh
    echo "✅ Themes installed."
}

chsh -s $(which zsh)

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🚀 Installing Oh My Zsh..."
    
    export RUNZSH=no
    export CHSH=no
    
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    copy-theme
else
    echo "ℹ️ Oh My Zsh is already installed."
    copy-theme
fi

./zsh-plugin-install.sh

echo "✨ INSTALLATION COMPLETE! Restart your terminal."