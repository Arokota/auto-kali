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
echo "Installing Suckless... (1/6)"
cd ~
git clone https://github.com/Arokota/st > /dev/null 2>&1
cd st
apt-get install -y pkg-config > /dev/null 2>&1
apt install libxft-dev -y  > /dev/null 2>&1
make install  > /dev/null 2>&1
echo -e "*.alpha: 0.9\n*.font: Liberation Mono:pixelsize=18" > ~/.Xdefaults

#Setup Empire
echo "Installing Empire... (2/6)"
cd ~
git clone https://github.com/EmpireProject/Empire -b dev  > /dev/null 2>&1
cd Empire
./setup/install.sh  > /dev/null 2>&1


#Setup Fish
echo "Installing Fish... (3/6)"
wget -q https://download.opensuse.org/repositories/shells:fish:release:2/Debian_8.0/Release.key -O - | apt-key add -
apt update  > /dev/null 2>&1
apt install -y fish  > /dev/null 2>&1
chsh -s `which fish`  > /dev/null 2>&1


#Setup gdb-peda
echo "Installing gdb-peda... (4/6)"
git clone https://github.com/longld/peda.git ~/peda  > /dev/null 2>&1
echo "source ~/peda/peda.py" >> ~/.gdbinit 

#Various Packages
echo "Installing various packages... (5/6)"
apt-get install -y screenfetch feh lxappearance gtk-chtheme i3 i3blocks  > /dev/null 2>&1



#Setup dotfiles
echo "Copying over dotfiles... (6/6)"
mkdir -p ~/.config/  #Incase directory doesn't exist yet
cp -r ~/auto-config/dotfiles/* ~/.config/. #Copies any dotfiles I have over to .config

echo "All done!"
echo "Going down for a reboot!"
sleep 5
reboot
