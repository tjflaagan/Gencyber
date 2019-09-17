#!/bin/sh

# Turn off auto suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0

# Turn off blank screen in power settings
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Update
apt upgrade -y 
apt update -y 

# Install sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt update -y 
apt install sublime-text

# Install and run docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list
apt update -y
apt install -y docker-ce docker-compose
systemctl enable docker
systemctl start docker

# Install terminator
apt install -y terminator

# Install utils
apt update -y --fix-missing
apt install socat
apt install openssh-server
apt install autossh
apt install apache2
apt install nginx
apt install net-tools
apt install vim

# Disable services
systemctl disable nginx
systemctl disable apache2

# Clean up
apt autoremove -y 
apt autoclean -y 
history -c && rm ~/.bash_history

# Done
sleep 5
shutdown -r 0 
