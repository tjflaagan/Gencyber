#!/bin/sh

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo"
        exit 1
fi

# This upgrade will need user input to complete
export DEBIAN_FRONTEND=noninteractive
apt upgrade -y 
apt update -y 

# Install and run docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list
apt update -y --fix-missing
apt install -y jq
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
apt install -y sublime-text

# Install Atom
wget -O /tmp/atom-amd64.deb https://github.com/atom/atom/releases/download/v1.49.0/atom-amd64.deb                                                                                                                                          
dpkg -i /tmp/atom-amd64.deb    

# Install terminator
apt install -y terminator

# Install gobuster
apt install -y gobuster

# Install responder
git clone https://github.com/lgandx/Responder.git /opt/responder

# Install enum4linux-ng
git clone https://github.com/cddmp/enum4linux-ng.git /opt/enum4linux-ng

# Set a few terminator preferences
install -D /dev/null ~/.config/terminator/config
printf "[global_config]\n  inactive_color_offset = 1.0\n[keybindings]\n[profiles]\n  [[default]]\n    cursor_color = \"#aaaaaa\"\n    foreground_color = \"#ffffff\"\n    scrollback_lines = 4000\n[layouts]\n  [[default]]\n    [[[child1]]]\n      parent = window0\n      type = Terminal\n    [[[window0]]]\n      parent = \"\"\n      type = Window\n[plugins]" > ~/.config/terminator/config

# Install GDB GEF 
wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# Installing python pwntools
pip install pwntools

# Install autossh
apt install -y autossh

# Install ffuff
cd /opt
curl -sL https://api.github.com/repos/ffuf/ffuf/releases/latest | jq -r '.assets[].browser_download_url' | grep linux_amd64 | xargs -I{} sh -c 'wget -q -O - {} | tar zxf -'
cd

# Install openvmtools
apt install -y open-vm-tools-desktop

# Install Bettercap
apt -y install libnetfilter-queue-dev libpcap-dev libusb-1.0-0-dev
apt install -y bettercap 

# Install cme
apt install -y crackmapexec

# Install boostnote
boost_deb_url="https://github.com$(curl -Ls https://github.com/BoostIO/boost-releases/releases/latest | egrep -o '/BoostIO/boost-releases/releases/download/.+.deb')"
cd ~/Downloads
wget -O boostnote.deb "$boost_deb_url"
apt-get -y install gconf2 gvfs-bin
dpkg -i boostnote.deb
rm boostnote.deb

# Init msfdb
systemctl start postgresql
systemctl enable postgresql
msfdb init

# Installing pip
python2 -m pip install pipenv
python3 -m pip install pipenv

# Install impacket
curl -s "https://api.github.com/repos/SecureAuthCorp/impacket/releases/latest" | jq -r '.assets[0].browser_download_url' | wget -qi - -O /opt/impacket.tar.gz
tar -xvf /opt/impacket.tar.gz -C /opt

if [ `echo $DESKTOP_SESSION` == "gnome" ]
then
    # Turn off auto suspend
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0

    # Turn off blank screen in power settings
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

    # Disable terminal transparency
    profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-transparent-background false

    # Turn off inteligent autohide on dash to dock
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed 'true'

    # Set app favorites for dock
    gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'terminator.desktop', 'org.gnome.Terminal.Desktop', 'org.gnome.Nautilus.desktop', 'kali-burpsuite.desktop', 'leafpad.desktop', 'wireshark.desktop', 'sublime_text.desktop']"
elif [ `echo $DESKTOP_SESSION` == "lightdm-xsession" ] 
then
    xset -dpms
    xset s off
    # Turn off auto suspend
    # Turn off blank screen in power settings
    # Disable terminal transparency
    # Set app favorites for launcher
fi

# Turn off Firefox captive portal detection by default
x=$(grep "Path" ~/.mozilla/firefox/profiles.ini | cut -d "=" -f2)
echo "user_pref(\"network.captive-portal-service.enabled\", false);" >> "$HOME/.mozilla/firefox/$x/user.js"

# Fix ssh on VM
echo "Host *" > ~/.ssh/config
echo "	IPQoS lowdelay throughput" >> ~/.ssh/config

# Unzip rockyou
gunzip /usr/share/wordlists/rockyou.txt.gz

# Get rid of unused directories
rmdir ~/Music ~/Public ~/Pictures ~/Videos ~/Templates

if [[ -z $SUDO_USER ]]; then
        echo "Script not ran with sudo. You may need to add your user to docker group manually"
else
        usermod -aG docker $SUDO_USER
fi

# Clean up
apt autoremove -y 
apt autoclean -y 
history -c && rm ~/.bash_history

# Done
sleep 5
shutdown -r 0 
