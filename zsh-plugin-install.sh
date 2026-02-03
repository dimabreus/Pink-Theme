#!/bin/bash

PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

echo "📥 Installing plugins for ZSH..."

[ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"

[ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR/zsh-syntax-highlighting"

echo "✅ Success! Restart terminal"