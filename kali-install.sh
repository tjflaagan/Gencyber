#!/bin/sh

apt full-upgrade -y 

# Install and run docker
echo -e "Installing docker...\n"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-compose
systemctl start docker

# Install sublime
echo -e "Installing Sublime Text...\n"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt update
apt install sublime-text

# Install terminator
apt install -y terminator
# Install openvmtools
apt install -y open-vm-tools-desktop

# Install Empire
cd /opt
git clone https://github.com/EmpireProject/Empire.git

# Turn off inteligent autohide on dash to dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed 'true'

# Set blank screen in power saving to never and turn off auto suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
gsettings set org.gnome.desktop-session idle-delay 3000

# Set app favorites
gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'terminator.desktop', 'org.gnome.Terminal.Desktop', 'org.gnome.Nautilus.desktop', 'kali-burpsuite.desktop', 'leafpad.desktop', 'wireshark.desktop', 'sublime_text.desktop']"

# Clean up
apt autoremove -y 
apt autoclean -y 

# Done
echo -e "Done!\n"
sleep 10
echo -e "Time to reboot for all changes to take affect!\n"
shutdown -r 0 