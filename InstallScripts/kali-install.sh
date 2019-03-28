#!/bin/sh

# Turn off auto suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0

# Turn off blank screen in power settings
gsettings set org.gnome.desktop.session idle-delay 0

# This upgrade will need user input to complete
export DEBIAN_FRONTEND=noninteractive
apt upgrade -y 
apt update -y 

# Install and run docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list
apt update -y
apt install -y docker-ce docker-compose
systemctl enable docker
systemctl start docker

# Pulling a few containers
docker pull tleemcjr/metasploitable2
docker pull raesene/bwapp

# Adding SDR packages
apt install -y gcc-multilib
apt install -y gqrx pkg-config #librtlsdr-dev
ln -sf /usr/lib/x86_64-linux-gnu/libvolk.so.1.3.1 /usr/lib/x86_64-linux-gnu/libvolk.so.1.3

# librtlsdr from source to get proper config for dump1090
apt install -y cmake libusb-1.0-0-dev
git clone git://git.osmocom.org/rtl-sdr.git /opt/rtl-sdr
cd /opt/rtl-sdr
mkdir build
cd build
cmake ..
make
make install

# Get dump1090 for decoding ADS-B and install
git clone https://github.com/antirez/dump1090.git /opt/dump1090
cd /opt/dump1090
make 

# Install sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt update -y 
apt install sublime-text

# Install terminator
apt install -y terminator

# Set a few terminator preferences
install -D /dev/null ~/.config/terminator/config
printf "[global_config]\n  inactive_color_offset = 1.0\n[keybindings]\n[profiles]\n  [[default]]\n    cursor_color = \"#aaaaaa\"\n    foreground_color = \"#ffffff\"\n    scrollback_lines = 2500\n[layouts]\n  [[default]]\n    [[[child1]]]\n      parent = window0\n      type = Terminal\n    [[[window0]]]\n      parent = \"\"\n      type = Window\n[plugins]" > ~/.config/terminator/config

# Install GDB PEDA 
git clone https://github.com/longld/peda.git ~/.peda
echo "source ~/.peda/peda.py" >> ~/.gdbinit

# Installing python pwntools
pip install pwntools

# Install autossh
apt install autossh

# Install openvmtools
apt install -y open-vm-tools-desktop

# Download Empire
git clone https://github.com/EmpireProject/Empire.git /opt/Empire

# Install cme
apt install -y crackmapexec

# Turn off inteligent autohide on dash to dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed 'true'

# Set app favorites for dock
gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'terminator.desktop', 'org.gnome.Terminal.Desktop', 'org.gnome.Nautilus.desktop', 'kali-burpsuite.desktop', 'leafpad.desktop', 'wireshark.desktop', 'sublime_text.desktop']"

# Fix ssh on VM
echo "Host *" > ~/.ssh/config
echo "	IPQoS lowdelay throughput" >> ~/.ssh/config

# Get rid of unused directories
rmdir ~/Music ~/Public ~/Pictures ~/Videos ~/Templates

# Clean up
apt autoremove -y 
apt autoclean -y 
history -c && rm ~/.bash_history

# Done
sleep 5
shutdown -r 0 
