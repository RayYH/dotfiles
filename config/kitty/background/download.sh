#!/usr/bin/env bash

CURRENT_DIR="$(cd $(dirname "$BASH_SOURCE[0]") && pwd)"

if [ -f "$CURRENT_DIR/wallpaper.png" ]; then
    return
fi

wget https://backiee.com/static/wallpapers/1920x1080/224618.jpg -O "$CURRENT_DIR/wallpaper.jpg"

# convert to PNG format
convert "$CURRENT_DIR/wallpaper.jpg" "$CURRENT_DIR/wallpaper.png"
