#!/bin/bash

# Vérifie si le Wi-Fi (la radio) est activé ou désactivé
STATUS=$(nmcli radio wifi)

if [[ "$STATUS" == "enabled" ]]; then
    # La radio est active (même si vous n'êtes connecté à rien)
    # Ne retourne rien, ou une chaîne vide. 
    # C'est le module 'network' classique qui prendra le relais.
    echo ""
elif [[ "$STATUS" == "disabled" ]]; then
    # La radio est désactivée (Mode avion)
    echo "󰀝"
    # 󰛁 est l'icône Avion (Aeroplane) dans Nerd Fonts
fi