#!/bin/sh

# Turn off auto suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0

# Turn off blank screen in power settings
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Update
apt upgrade -y 
apt update -y --fix-missing

# Install sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt update -y 
apt install -y sublime-text

# Install terminator
apt install -y terminator

# Install utils
apt install -y socat
apt install -y openssh-server
apt install -y autossh
apt install -y apache2
apt install -y nginx
apt install -y net-tools
apt install -y vim
apt install -y open-vm-tools-desktop
apt install -y python-pip 
apt install -y git
apt install -y curl

# Install docker
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" 
apt update -y
apt install -y docker-ce docker-compose
systemctl enable docker
systemctl start docker

# Installing ansible
sudo apt install -y ansible

# Disable services
systemctl disable nginx
systemctl disable apache2

# Clean up
apt autoremove -y 
apt autoclean -y 

# Get rid of unused directories
rmdir ~/Music ~/Public ~/Pictures ~/Videos ~/Templates

# Done
sleep 5
shutdown -r 0 
