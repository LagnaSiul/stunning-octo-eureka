#!/bin/bash
# Game Mode para Hyprland (Toggle con estado en /tmp y Mako icons)

STATE_FILE="/tmp/hypr_gamemode.status"

if [ ! -f "$STATE_FILE" ]; then
    # --- ACTIVAR GAME MODE ---
    touch "$STATE_FILE"

    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:passes 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    
    pkill -9 swww-daemon 2>/dev/null
    pkill -9 awww-daemon 2>/dev/null
    
    # Mako busca el icono "preferences-desktop-gaming" o "bell" en tu tema activo
    notify-send -e -u low -i "preferences-desktop-gaming" "Gamemode activado" "Todas las animaciones desactivadas."
    exit 0
else
    # --- DESACTIVAR GAME MODE ---
    rm -f "$STATE_FILE"

    hyprctl reload
    
    pkill -9 swww-daemon 2>/dev/null
    pkill -9 awww-daemon 2>/dev/null
    sleep 0.2

    nohup swww-daemon --format xrgb >/dev/null 2>&1 &
    
    notify-send -e -u normal -i "dialog-information" "Gamemode desactivado" "Sistema restaurado a la normalidad."
    exit 0
fi
