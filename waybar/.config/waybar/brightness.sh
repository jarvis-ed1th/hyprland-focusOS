#!/bin/bash

# Définition du seuil minimum (en pourcentage)
MIN_LEVEL=5

# Gestion de l'argument (up ou down)
case "$1" in
    up)
        # Augmenter de 5%
        brightnessctl set +5%
        ;;
    down)
        # Baisser de 5%
        brightnessctl set 5%-

        # Récupérer le niveau actuel en pourcentage
        # brightnessctl -m sort un format CSV : device,class,valeur,pourcentage,max
        current_opt=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')

        # Si le niveau est inférieur au minimum, on le force au minimum
        if [ "$current_opt" -lt "$MIN_LEVEL" ]; then
            brightnessctl set ${MIN_LEVEL}%
        fi
        ;;
esac