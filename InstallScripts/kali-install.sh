#!/usr/bin/zsh

# Check perms
if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo"
        exit 1
fi


export DEBIAN_FRONTEND=noninteractive
# Update and upgrade system
apt -qq update -y 
apt -qq update -y --fix-missing
apt -qq upgrade -y 
apt 

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
apt install -y audacity
echo 'blacklist dvb_usb_rtl28xxu' | sudo tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf

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
cd ~

# Install sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt update -y 
apt install -y sublime-text

# Install atom
wget -O /tmp/atom-amd64.deb https://github.com/atom/atom/releases/download/v1.49.0/atom-amd64.deb
dpkg -i /tmp/atom-amd64.deb
rm -f /tmp/atom-amd64.deb

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

# Install GDB GEF 
wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# Installing pip (python3 only)
sudo apt install -y python3-pip

# Installing python pwntools
pip install -y pwntools

# Install openvmtools
apt install -y open-vm-tools-desktop

# Install Bettercap
apt install -y libnetfilter-queue-dev libpcap-dev libusb-1.0-0-dev
apt install -y bettercap 

# Install impacket
git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket
pip3 install -r /opt/impacket/requirements.txt
python3 ./setup.py install

#Install Ghidra
apt --fix-broken install
apt update --fix-missing -y -qq
apt install -y openjdk-11-jdk
git clone https://github.com/bkerler/ghidra_installer /opt/ghidra_installer
cd /opt/ghidra_installer
./install-ghidra.sh
cd ~

# Install car hacking tools
# Install Dependencies
apt install -y libsdl2-dev libsdl2-image-dev

# Install canutils
apt install -y can-utils

# Install ICSim
git clone https://github.com/zombieCraig/ICSim.git /opt/ICSim
zsh /opt/ICSim/setup_vcan.sh
make

# Install scantool of obd2
apt install -y scantool


# Canopy install
git clone https://github.com/Tbruno25/canopy /opt/canopy
cd /opt/canopy
pip3 install -r requirements.txt
cd ~

# Check if we're sudo or root
if [[ -z $SUDO_USER ]]; then
  cf_home="~"
  cf_user="root"
else
  cf_home=$(getent passwd $SUDO_USER | cut -d: -f6)
  cf_user=$SUDO_USER
fi
cf_path=$cf_home"/course_files"

# Fix ssh on VM
echo "Host *" > $cf_home/.ssh/config
echo "  IPQoS lowdelay throughput" >> $cf_home/.ssh/config

# Set a few terminator preferences 
install -D /dev/null $cf_home/.config/terminator/config
printf "[global_config]\n  inactive_color_offset = 1.0\n[keybindings]\n[profiles]\n  [[default]]\n    cursor_color = \"#aaaaaa\"\n    foreground_color = \"#ffffff\"\n    scrollback_lines = 4000\n[layouts]\n  [[default]]\n    [[[child1]]]\n      parent = window0\n      type = Terminal\n    [[[window0]]]\n      parent = \"\"\n      type = Window\n[plugins]" > $cf_home/.config/terminator/config

# Unzip rockyou
gunzip /usr/share/wordlists/rockyou.txt.gz

# Set vi line numbers
echo "set number" >> /etc/vim/vimrc

# Run ff
firefox
# Disable firefox captive portal detect and password history - set homepage
# This only works if firefox has already ran
ff_profiles=$(grep "Path" $cf_home/.mozilla/firefox/profiles.ini | cut -d "=" -f2)
for ff_profile in $ff_profiles; do
    echo "user_pref(\"network.captive-portal-service.enabled\", false);" >> "$cf_home/.mozilla/firefox/$ff_profile/user.js"
    echo "user_pref(\"signon.rememberSignons\", false);" >> "$cf_home/.mozilla/firefox/$ff_profile/user.js"
    echo "user_pref(\"browser.startup.homepage\", \"localhost:8000\");" >> "$cf_home/.mozilla/firefox/$ff_profile/user.js"
done

# Clean up
apt autoremove -y 
apt autoclean -y 
rm -f ~/.zsh_history

# Done
sleep 3
shutdown -r now
