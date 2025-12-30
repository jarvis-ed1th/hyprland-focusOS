#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$BASE_DIR/venv-theme"
REQ_FILE="$BASE_DIR/requirements.txt"
SCRIPT_PY="$BASE_DIR/generate_theme.py"
STATE_FILE="/tmp/hypr_theme_mode"

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install -r "$REQ_FILE"
fi

# 1. Détecter le mode actuel (par défaut light)
if [ ! -f "$STATE_FILE" ]; then
    echo "light" > "$STATE_FILE"
fi
CURRENT_MODE=$(cat "$STATE_FILE")

# 2. Inverser le mode
if [ "$CURRENT_MODE" == "light" ]; then
    # 1. Mise à jour des variables système (GTK)
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'   
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 
    # 2. Exécuter ton script Python
    "$VENV_DIR/bin/python3" "$SCRIPT_PY" "dark"
    echo "dark" > "$STATE_FILE"
else
    # 1. Mise à jour des variables système (GTK)
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 


    # 2. Exécuter ton script Python
    "$VENV_DIR/bin/python3" "$SCRIPT_PY" "light"
    echo "light" > "$STATE_FILE"
fi

# 4. Sauvegarder le nouvel état


# 5. Rafraîchir les applications
killall -SIGUSR2 waybar        # Recharge le CSS de Waybar
killall -SIGUSR1 kitty         # Recharge la config de Kitty
killall hyprpaper
hyprpaper &
hyprctl reload                 # Recharge la config Hyprland (bordures)