#!/bin/bash

# Fonction de nettoyage (trap)
# Elle s'assure de remettre la config normale à la fin
cleanup() {
    # On remet le comportement par défaut (changez le 1 si votre défaut est différent)
    hyprctl keyword input:follow_mouse 1
    hyprctl keyword input:float_switch_override_focus 1
}
trap cleanup EXIT

# 1. VERROUILLAGE DU FOCUS
# follow_mouse 0 : La souris ne change plus le focus globalement
hyprctl keyword input:follow_mouse 0
# float_switch_override_focus 0 : Empêche le focus de "tomber" sur la fenêtre tuilée en dessous
hyprctl keyword input:float_switch_override_focus 0

# 2. LANCEMENT DE L'APPLICATION
# $@ contient votre commande (kitty ... nmtui)
$@ &
PID=$!

# On attend un instant que la fenêtre apparaisse et prenne le focus
sleep 0.2

# 3. BOUCLE DE SURVEILLANCE
while true; do
    # Si le processus est mort (fermé par Echap, q, ou bouton close), on arrête
    if ! kill -0 $PID 2>/dev/null; then
        break
    fi

    # Quelle est la fenêtre qui a le focus ACTUELLEMENT ?
    ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r '.class')

    # Si la fenêtre active n'est PLUS notre popup "dotfiles-floating"
    # C'est que l'utilisateur a CLIQUÉ ailleurs (car le survol est désactivé)
    if [[ "$ACTIVE_CLASS" != "dotfiles-floating" ]]; then
        # On ferme la fenêtre proprement
        kill $PID
        break
    fi

    # Petite pause pour ne pas surcharger le CPU
    sleep 0.1
done

# Le "trap cleanup" s'exécute automatiquement ici