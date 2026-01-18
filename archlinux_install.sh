#!/bin/bash

echo "--------------------------------------------------"
echo "----------     FocusOS Installation     ----------"
echo "--------------------------------------------------"
echo ""

echo "--> Update system"
sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    echo "--> Yay installation"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "--> Yay already installed"
fi

if [ -f "pkglist.txt" ]; then
    echo "--> Official packages installation"
    sudo pacman -S --needed --noconfirm - < pkglist.txt
fi

if [ -f "aurlist.txt" ]; then
    echo "--> AUR packages installation"
    yay -S --needed --noconfirm - < aurlist.txt
fi

echo "--> Configuration with stow"
stow -R */

echo "--> Systemd activation"

SERVICES=(
    "NetworkManager.service" 
    "bluetooth.service"       
    "tlp.service"             
    "ly.service"              
    "udisks2.service"         
)

for service in "${SERVICES[@]}"; do
    echo "$service activation"
    sudo systemctl enable --now "$service"
done

# In case of blocked bluetooth
if command -v rfkill &> /dev/null; then
    echo "--> Unblock bluetooth"
    sudo rfkill unblock bluetooth
fi

echo "----------    Successful Installation   ----------"