#!/bin/bash

LOGO_DIR="$HOME/.config/fastfetch/Icons/"

RANDOM_LOGO=$(find "$LOGO_DIR" -type f | grep -v "off" | shuf -n 1)

if [ -z "$RANDOM_LOGO" ]; then
    echo "Error: Directory $LOGO_DIR have not files"
    exit 1
fi

fastfetch --logo "$RANDOM_LOGO"