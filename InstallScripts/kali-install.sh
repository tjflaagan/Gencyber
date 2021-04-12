#!/bin/sh

# Check perms
if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo"
        exit 1
fi


DEBIAN_FRONTEND='noninteractive' apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'
# Update and upgrade system
apt -qq update -y 
apt -qq update -y --fix-missing
apt -qq upgrade -y 

# Install and run docker
apt install -y docker-io
apt install -y docker-compose
systemctl enable docker
systemctl start docker

if [[ -z $SUDO_USER ]]; then
        echo "Script not ran with sudo. You may need to add your user to docker group manually"
else
        usermod -aG docker $SUDO_USER
fi

# Pulling a few containers
docker pull tleemcjr/metasploitable2
docker pull raesene/bwapp
docker pull bkimminich/juice-shop
docker pull byt3bl33d3r/crackmapexec

# Adding SDR packages
apt install -y gcc-multilib
apt install -y gqrx-sdr
apt install -y pkg-config
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

# Install terminator
apt install -y terminator

# Install ffuf
apt install -y ffuf

# Install jq 
apt install -y jq

# Install autossh
apt install -y autossh

# Install responder
git clone https://github.com/lgandx/Responder.git /opt/responder

# Install enum4linux-ng
git clone https://github.com/cddmp/enum4linux-ng.git /opt/enum4linux-ng

# Set a few terminator preferences (only for the root account)
install -D /dev/null ~/.config/terminator/config
printf "[global_config]\n  inactive_color_offset = 1.0\n[keybindings]\n[profiles]\n  [[default]]\n    cursor_color = \"#aaaaaa\"\n    foreground_color = \"#ffffff\"\n    scrollback_lines = 4000\n[layouts]\n  [[default]]\n    [[[child1]]]\n      parent = window0\n      type = Terminal\n    [[[window0]]]\n      parent = \"\"\n      type = Window\n[plugins]" > ~/.config/terminator/config

# Install GDB GEF 
wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# Installing pip (python3 only)
sudo apt install -y python3-pip

# Installing python pwntools
pip install -y pwntools

# Install openvmtools
apt install -y open-vm-tools-desktop

# Install Bettercap
apt -y install libnetfilter-queue-dev libpcap-dev libusb-1.0-0-dev
apt install -y bettercap 

# Install impacket
git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket
pip3 install -r /opt/impacket/requirements.txt
python3 ./setup.py install

# Fix ssh on VM
echo "Host *" > ~/.ssh/config
echo "  IPQoS lowdelay throughput" >> ~/.ssh/config

# Unzip rockyou
gunzip /usr/share/wordlists/rockyou.txt.gz

# Get rid of unused directories
rmdir ~/Music ~/Public ~/Pictures ~/Videos ~/Templates

# Clean up
apt autoremove -y 
apt autoclean -y 
rm -f ~/.zsh_history

# Done
sleep 5
shutdown -r 0 
