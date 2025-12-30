#!/bin/bash

# Temp folder private for user
STATUS_FILE="${XDG_RUNTIME_DIR}/status_standby.pid"

if [ "$1" = "start" ]; then
    # Create a "status file" when system is locked
    echo "lock" > "$STATUS_FILE"
elif [ "$1" = "stop" ]; then
    # Suppress the "status file" when system unlocked
    if [ -f "$STATUS_FILE" ]; then
        rm "$STATUS_FILE"
    fi
elif [ "$1" = "restart" ]; then
    # Shutdown screen if time's up and system locked
    if [ -f "$STATUS_FILE" ]; then
        hyprctl dispatch dpms off
    fi
fi