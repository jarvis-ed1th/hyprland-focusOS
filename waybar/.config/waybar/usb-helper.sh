#!/bin/bash

# Fonction pour lister les USB montés
get_mounted_usb() {
    lsblk -J -o NAME,TRAN,MOUNTPOINT | jq -c '
        .blockdevices[] 
        | select(.tran == "usb") 
        | (.children // []) + [.] 
        | .[] 
        | select(.mountpoint != null)
    '
}

case "$1" in
    "status")
        # Récupère les USB montés
        MOUNTED=$(get_mounted_usb)
        COUNT=$(echo "$MOUNTED" | grep -c "mountpoint")

        if [ "$COUNT" -gt 0 ]; then
            # Créer une info-bulle avec le nom des points de montage
            TOOLTIP=$(echo "$MOUNTED" | jq -r '.mountpoint' | tr '\n' '\r')
            # Sortie JSON pour Waybar
            echo "{\"text\": \" $COUNT ⏏\", \"tooltip\": \"Monté:\r$TOOLTIP\", \"class\": \"active\"}"
        else
            # Si rien n'est monté, on affiche rien (ou une icône vide)
            echo "{\"text\": \"\", \"class\": \"inactive\"}"
        fi
        ;;
    
    "unmount")
        # Récupère la liste des partitions montées et tente de les démonter
        get_mounted_usb | jq -r '.name' | while read -r dev_name; do
            udisksctl unmount -b "/dev/$dev_name"
        done
        
        notify-send "USB Helper" "Tous les périphériques USB ont été démontés."
        # Force la mise à jour de waybar immédiatement (signal optionnel)
        pkill -RTMIN+8 waybar
        ;;
esac