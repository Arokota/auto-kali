#!/bin/bash

#Author: @Arokota
#Description: This script installs a lot of my premade dotfiles and tools I like to use on engagements.
#Expect updates often and stuff to break :)

if [ $(uname -n) != "kali" ]
then
	echo "It seems like your not running Kali, this is only intended to work on Kali installs."
	exit 1
fi

#Setup Suckless Terminal
echo "Installing Suckless..."
cd ~
git clone https://github.com/Arokota/st
cd st
apt-get install -y pkg-config
apt install libxft-dev -y
make install
echo -e "*.alpha: 0.9\n*.font: Liberation Mono:pixelsize=18" > ~/.Xdefaults"
echo "Success! (1/6)"

#Setup Empire
echo "Installing Empire..."
cd ~
git clone https://github.com/EmpireProject/Empire -b dev
cd Empire
./setup/install.sh
echo "Success! (2/6)"


#Setup Fish
echo "Installing Fish..."
wget -q https://download.opensuse.org/repositories/shells:fish:release:2/Debian_8.0/Release.key -O - | apt-key add -
apt update
apt install -y fish
echo "chsh -s `which fish`"
echo "Success! (3/6)"


#Setup gdb-peda
echo "Installing gdb-peda..."
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "Success! (4/6)"

#Various Packages
echo "Installing various packages..."
apt-get install -y screenfetch feh lxappearance gtk-chtheme i3
echo "Success! (5/6)"



#Setup dotfiles
echo "Copying over dotfiles..."
mkdir -p ~/.config/  #Incase directory doesn't exist yet
cp -r ~/auto-config/dotfiles ~/.config/ #Copies any dotfiles I have over to .config

echo "Success! (6/6)"

echo "Going down for a reboot!"
sleep 5
reboot
