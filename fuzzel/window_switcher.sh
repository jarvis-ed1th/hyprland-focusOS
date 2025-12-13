#!/bin/bash

# Vérification basique
if ! command -v jq &> /dev/null; then notify-send "Erreur" "Installez jq"; exit 1; fi

# --- FONCTION DE RECHERCHE DU NOM ---
get_desktop_name() {
    local class_name=$1
    local lower_class=$(echo "$class_name" | tr '[:upper:]' '[:lower:]')
    
    # Chemins de recherche (Chrome installe les PWA dans .local/share/applications)
    local dirs=(
        "$HOME/.local/share/applications"
        "/usr/share/applications" 
        "/var/lib/flatpak/exports/share/applications" 
        "/var/lib/snapd/desktop/applications"
    )

    # Candidats potentiels de nom de fichier
    # 1. Le nom exact de la classe (C'est ce qui marchera pour Todoist/Chrome PWA)
    # 2. Le nom en minuscule
    # 3. Le dernier bout du nom (ex: org.kde.dolphin -> dolphin)
    local candidates=(
        "$class_name.desktop" 
        "$lower_class.desktop" 
        "${lower_class##*.}.desktop"
    )

    for dir in "${dirs[@]}"; do
        for file in "${candidates[@]}"; do
            if [ -f "$dir/$file" ]; then
                # On extrait la ligne "Name="
                # On enlève le "Name=" du début
                local found_name=$(grep -m 1 "^Name=" "$dir/$file" | cut -d= -f2-)
                if [ -n "$found_name" ]; then
                    echo "$found_name"
                    return 0
                fi
            fi
        done
    done
    return 1
}

# --- MAIN ---

ids=()
display_names=()

# On récupère les fenêtres
RAW_DATA=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id != -1) | "\(.address)\t\(.workspace.id)\t\(.class)\t\(.title)"')

while IFS=$'\t' read -r id ws class title; do
    
    # 1. On tente de trouver le "Joli Nom" via le fichier .desktop
    # Cela va maintenant fonctionner pour chrome-dlgohin... (Todoist)
    pretty_name=$(get_desktop_name "$class")

    # 2. Si aucun fichier .desktop n'est trouvé, on se rabat sur des règles manuelles
    if [ -z "$pretty_name" ]; then
        lower_class=$(echo "$class" | tr '[:upper:]' '[:lower:]')
        
        # Si c'est une appli Chrome SANS fichier desktop trouvé, on utilise le titre nettoyé
        if [[ "$lower_class" == chrome-* ]]; then
            pretty_name="$title"
            pretty_name="${pretty_name// - Google Chrome/}"
            pretty_name="${pretty_name// - Chromium/}"
        elif [[ "$lower_class" == "code-oss" ]]; then 
            pretty_name="Code OSS"
        else 
            # Dernier recours : on affiche la classe telle quelle
            pretty_name="$class"
        fi
    fi

    # 3. Construction de l'affichage ÉPURÉ
    # On n'affiche QUE : [WS] Nom de l'appli
    # Pas de tiret, pas de titre de fenêtre, juste l'essentiel.
    
    display_str="[$ws] $pretty_name"

    ids+=("$id")
    display_names+=("$display_str")

done <<< "$RAW_DATA"

if [ ${#ids[@]} -eq 0 ]; then exit 0; fi

# Lancement de Fuzzel
# On passe --index pour récupérer le numéro de ligne au lieu du texte
SELECTED_INDEX=$(printf "%s\n" "${display_names[@]}" | fuzzel -d --prompt="Switch: " --width=50 --index)

# Activation
if [ -n "$SELECTED_INDEX" ]; then
    TARGET_ID="${ids[$SELECTED_INDEX]}"
    hyprctl dispatch focuswindow address:"$TARGET_ID"
fi