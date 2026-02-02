#!/bin/bash

# Функция для вывода текущей раскладки
get_layout() {
    # Берем активную раскладку, обрезаем до 2 букв (English -> En) и делаем капсом
    layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | cut -c1-2 | tr '[:lower:]' '[:upper:]')
    # Для JSON формата Waybar (чтобы не было буферизации)
    echo "{\"text\": \"$layout\", \"tooltip\": \"Current Layout: $layout\"}"
}

# Выводим текущее состояние сразу при запуске
get_layout

# Слушаем сокет Hyprland. Как только прилетает событие 'activelayout', обновляем статус
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if [[ $line == *"activelayout"* ]]; then
        get_layout
    fi
done
