# ly
sudo rm /etc/ly/config.ini
sudo cp ~/dotfiles/.system-configs/ly/config.ini /etc/ly/config.ini

# vpn
sudo rm /etc/vpnc/n7-vpn.conf
sudo cp ~/dotfiles/.system-configs/vpn/n7-vpn.conf /etc/vpnc/n7-vpn.conf

echo "Configuration files up to date"