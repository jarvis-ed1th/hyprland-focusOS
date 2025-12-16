#!/bin/bash

# MODIFICATION ICI : On utilise XDG_RUNTIME_DIR au lieu de /tmp
PID_FILE="${XDG_RUNTIME_DIR}/dpms_timer.pid"

if [ "$1" = "start" ]; then
    # Lancer la commande d'extinction après 10 secondes en arrière-plan
    # Note: On s'assure que hyprctl est bien dans le path ou on utilise le chemin absolu si besoin
    ( sleep 10 && hyprctl dispatch dpms off ) &
    
    echo $! > "$PID_FILE"
    
elif [ "$1" = "stop" ]; then
    if [ -f "$PID_FILE" ]; then
        SLEEP_PID=$(cat "$PID_FILE")
        # On vérifie que le processus existe toujours pour éviter les erreurs
        if ps -p $SLEEP_PID > /dev/null; then
            kill $SLEEP_PID
        fi
        rm "$PID_FILE"
    fi
elif [ "$1" = "restart" ]; then
    if [ -f "$PID_FILE" ]; then
        ( sleep 10 && hyprctl dispatch dpms off ) &
        echo $! > "$PID_FILE"
    fi
fi