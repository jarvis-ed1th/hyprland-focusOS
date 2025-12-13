#!/bin/bash

# Classe de la fenêtre à fermer automatiquement
TARGET_CLASS="kitty" # Remplacez par la classe que vous voulez (ex: 'kitty', 'firefox')
# Utilisez 'hyprctl activewindow' pour trouver la classe exacte

# Récupérer le chemin du socket d'événement d'Hyprland
# Il est généralement dans /tmp/hypr/$USER/ ou /run/user/$UID/hypr/
# On utilise la variable d'environnement HYPRLAND_INSTANCE_SIGNATURE pour être sûr
SOCKET_PATH="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

# Lancer socat pour écouter les événements 'focuswindow'
socat -U -T1 -t1 -  "UNIX-CONNECT:${SOCKET_PATH}" | while IFS= read -r event; do
    
    # On ne s'intéresse qu'aux événements où une nouvelle fenêtre gagne le focus
    if [[ $event == 'focuswindow'* ]]; then
        
        # Récupérer l'ID de la fenêtre qui a perdu le focus (elle est dans $FOCUS_ID)
        # L'événement focuswindow est sous la forme 'focuswindow>><adresse>,<workspace>'
        # On ignore l'adresse et le workspace ici car c'est la NOUVELLE fenêtre.
        
        # On doit interroger Hyprland pour connaître la fenêtre précédente.
        
        # --- VÉRIFICATION LÉGÈRE ---
        # Cette méthode est complexe car Hyprland n'envoie pas la classe de la fenêtre perdant le focus.
        # Nous allons donc vérifier si la CLASSE CIBLE est active. Si elle ne l'est pas, 
        # c'est qu'elle a perdu le focus et qu'on doit la fermer (si elle existe).
        
        ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r '.class')

        if [[ "$ACTIVE_CLASS" != "$TARGET_CLASS" ]]; then
            # Si la fenêtre active N'EST PAS la cible, on vérifie si une fenêtre cible existe.
            # Si elle existe, c'est qu'elle a perdu le focus et on la ferme.
            
            # Recherche d'une fenêtre de la classe cible
            WINDOW_TO_KILL=$(hyprctl clients -j | jq -r --arg target "$TARGET_CLASS" '.[] | select(.class == $target) | .address')

            if [[ -n "$WINDOW_TO_KILL" ]]; then
                # Si l'adresse est trouvée, on la ferme.
                hyprctl dispatch killwindow address:"$WINDOW_TO_KILL" &
                # & pour ne pas bloquer le script
            fi
        fi
    fi

done