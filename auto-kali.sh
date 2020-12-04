#!/bin/bash

#Author: @Arokota
#Description: This script installs a lot of my premade dotfiles and tools I like to use on engagements.
#Expect updates often and stuff to break :)

if [ $(uname -n) != "kali" ]
then
	echo "It seems like your not running Kali, this is only intended to work on Kali installs."
	exit 1
fi


red=$'\e[1;31m'
white=$'\e[0m'

#Help menu
usage()
{
	cat <<EOF
Usage: ${0##*/} [option]
  Options:
  --i3		Set up i3 as the default window manager
  --fish	Set up fish as the default shell
  --st		Install suckless utilities
  --help	Display this message

EOF
exit 0
}

#Parse agument bash style :) 
while :
do
    case $1 in
        i3|-i3|--i3)
            install_i3=true;
            ;;
        fish|-fish|--fish)
            install_fish=true;
            ;;
        st|-st|--st)
            install_st=true;
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            break
    esac
    shift
done

#Checking if we're root...cause permissions
if [ "$HOME" != "/root" ]
then
	echo "Please run while looged in as root\n"
	exit 1
fi

#Update
read -p "Would you like to update your Kali before running the script? (y/n)" answer
if [ $answer == "y" ]
then
	echo "$white Updating quick..."
	apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1
fi



clear
#Setup Suckless Terminal
if [ -n "$install_st" ]
then
	echo "Installing Suckless..."
	cd ~
	git clone https://github.com/Arokota/st > /dev/null 2>&1
	cd st
	apt-get install -y pkg-config > /dev/null 2>&1
	apt install libxft-dev -y  > /dev/null 2>&1
	make install  > /dev/null 2>&1
	echo -e "*.alpha: 0.9\n*.font: Liberation Mono:pixelsize=18" > ~/.Xdefaults
fi

#Setup Empire
#Disabled for now...out of date.  needs to be updated with new repo of Empire

#echo "Installing Empire... $red (2/6) $white"
#cd ~
#git clone https://github.com/EmpireProject/Empire -b dev  > /dev/null 2>&1
#cd Empire
#./setup/install.sh  > /dev/null 2>&1 #Hangs during install while asking for server encryption key -- enter one or just press enter to continue


#Setup Fish
if [ -n "$install_fish" ]
then
	echo "Installing Fish..."
	wget -q https://download.opensuse.org/repositories/shells:fish:release:2/Debian_8.0/Release.key -O - | apt-key add -
	apt update  > /dev/null 2>&1
	apt install -y fish  > /dev/null 2>&1
	chsh -s `which fish`  > /dev/null 2>&1
fi
#Downloading Python2 pip since it was removed from kali repos
cd /root/Downloads
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py


echo "Installing:"
echo "-golang and environment"
echo "-docker"
echo "-pip and pipenv"
echo "-patator"
echo "-htop"
echo "-dnsmasq"
echo "-nfs-server"
echo "-hcxtools"

apt-get install golang docker.io python3-dev python3-pip patator net-tools htop nfs-kernel-server dnsmasq hcxtools
#    realtek-rtl88xxau-dkms

python2 -m pip install pipenv
python3 -m pip install pipenv
apt-get remove mitmproxy
python3 -m pip install mitmproxy

#enable and start docker
systemctl stop docker &>/dev/null
echo '{"bip":"172.16.199.1/24"}' > /etc/docker/daemon.json
systemctl enable docker --no

#mitmproxy setup
mitmproxy &>/dev/null &
sleep 5
killall mitmproxy
# trust certificate
cp ~/.mitmproxy/mitmproxy-ca-cert.cer /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt
update-ca-certificates


#Go setup stuff
mkdir -p /root/.go
gopath_exp='export GOPATH="$HOME/.go"'
path_exp='export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"'
sed -i '/export GOPATH=.*/c\' ~/.profile
sed -i '/export PATH=.*GOPATH.*/c\' ~/.profile
echo $gopath_exp | tee -a "$HOME/.profile"
grep -q -F "$path_exp" "$HOME/.profile" || echo $path_exp | tee -a "$HOME/.profile"
. "$HOME/.profile"

echo "Installing Bettercap..."
apt-get install libnetfilter-queue-dev libpcap-dev libusb-1.0-0-dev
go get -v github.com/bettercap/bettercap

echo "Installing EAPHammer..."
cd ~/Downloads
git clone https://github.com/s0lst1c3/eaphammer.git
cd eaphammer
apt-get install $(grep -vE "^\s*#" kali-dependencies.txt  | tr "\n" " ")
chmod +x kali-setup
# remove prompts from setup script
sed -i 's/.*input.*update your package list.*/    if False:/g' kali-setup
sed -i 's/.*input.*upgrade your installed packages.*/    if False:/g' kali-setup
sed -i 's/.*apt.* install.*//g' kali-setup
./kali-setup
ln -s ~/Downloads/eaphammer/eaphammer /usr/local/bin/eaphammer


echo "Installing Gowitness..."
go get -v github.com/sensepost/gowitness

echo "Installing BloodHound..."
pip install bloodhound

# uninstall old version
apt-get remove bloodhound
rm -rf /opt/BloodHound-linux-x64 &>/dev/null

# download latest bloodhound release from github
release_url="https://github.com/$(curl -s https://github.com/BloodHoundAD/BloodHound/releases | egrep -o '/BloodHoundAD/BloodHound/releases/download/.{1,10}/BloodHound-linux-x64.zip' | head -n 1)" 
cd /opt
wget "$release_url"
unzip -o 'BloodHound-linux-x64.zip'
rm 'BloodHound-linux-x64.zip'

# fix white screen issue
echo -e '#!/bin/bash\n/opt/BloodHound-linux-x64/BloodHound --no-sandbox $@' > /usr/local/bin/bloodhound
chmod +x /usr/local/bin/bloodhound

# install Neo4J
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list
apt-get update
apt-get install neo4j

echo "Installing PCredsz..."
apt-get remove python-pypcap
apt-get install python-libpcap
cd ~/Downloads
git clone https://github.com/lgandx/PCredz.git
ln -s ~/Downloads/PCredz/Pcredz /usr/local/bin/pcredz

echo "Installing EavesARP"
cd ~/Downloads
git clone https://github.com/mmatoscom/eavesarp
cd eavesarp && python3 -m pip install -r requirements.txt
cd && ln -s ~/Downloads/eavesarp/eavesarp.py /usr/local/bin/eavesarp


echo "Installing Firefox..."

if [[ ! -f /usr/share/applications/firefox.desktop ]]
    then
        wget -O /tmp/firefox.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'
        cd /opt
        tar -xvjf /tmp/firefox.tar.bz2
        if [[ -f /usr/bin/firefox ]]; then mv /usr/bin/firefox /usr/bin/firefox.bak; fi
        ln -s /opt/firefox/firefox /usr/bin/firefox
        rm /tmp/firefox.tar.bz2

        cat <<EOF > /usr/share/applications/firefox.desktop
[Desktop Entry]
Name=Firefox
Comment=Browse the World Wide Web
GenericName=Web Browser
X-GNOME-FullName=Firefox Web Browser
Exec=/opt/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=firefox-esr
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=Firefox-esr
StartupNotify=true
EOF
fi

echo "Installing Chromium..."
apt-get install chromium
sed -i 's#Exec=/usr/bin/chromium %U#Exec=/usr/bin/chromium --no-sandbox %U#g' /usr/share/applications/chromium.desktop

#Setup gdb-peda
#Commented for pwndbg instead, kept for history sake
#echo "Installing gdb-peda... $red (4/6) $white"
#git clone https://github.com/longld/peda.git ~/peda  > /dev/null 2>&1
#echo "source ~/peda/peda.py" >> ~/.gdbinit 


echo "Instaling CrackMapExec..."
cme_dir="$(ls -d /root/.local/share/virtualenvs/* | grep CrackMapExec | head -n 1)"
if [[ ! -z "$cme_dir" ]]; then rm -r "${cme_dir}.bak"; mv "${cme_dir}" "${cme_dir}.bak"; fi
apt-get install libssl-dev libffi-dev python-dev build-essential
cd ~/Downloads
git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec && python3 -m pipenv install
python3 -m pipenv run python setup.py install
ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin/cme ~/usr/local/bin/cme
#apt-get install crackmapexec

echo "Installing Impacket..."
cd ~/Downloads
git clone https://github.com/CoreSecurity/impacket.git
cd impacket && python3 -m pipenv install
python3 -m pipenv run python setup.py install

echo "Installing PwnDBG..."
cd ~/Downloads
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh

echo "Unzipping RockYou..."
gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
ln -s /usr/share/wordlists ~/Downloads/wordlists 2>/dev/null

echo "Initializing MSFDB..."
systemctl start postgresql
systemctl enable postgresql
msfdb init


#Install i3
if [ -n "$install_i3" ]
then
	echo "Installing i3 and components..."
	apt-get install -y screenfetch feh lxappearance gtk-chtheme i3 i3blocks  > /dev/null 2>&1
	#Setup dotfiles
	echo "Copying over dotfiles... $red (6/6) $white"
	mkdir -p ~/.config/  #Incase directory doesn't exist yet
	cp -r ~/auto-kali/dotfiles/* ~/.config/. #Copies any dotfiles I have over to .config
fi


echo "Cleaing up..."
updatedb
rmdir ~/Music ~/Public ~/Videos ~/Templates &>/dev/null


echo "All done!"
echo "Going down for a reboot!"
sleep 5
reboot


