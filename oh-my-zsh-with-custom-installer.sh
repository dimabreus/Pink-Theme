#!/bin/bash

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

cp zsh/themes/* ~/.oh-my-zsh/themes/
cp zsh/zshrc ~/.zshrc