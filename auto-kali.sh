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

#Update
read -p "Would you like to update your Kali before running the script? (y/n)" answer
if [ $answer == "y" ]
then
	echo "$white Updating quick..."
	apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1
fi


clear
#Setup Suckless Terminal
echo "Installing Suckless... $red (1/6) $white"
cd ~
git clone https://github.com/Arokota/st > /dev/null 2>&1
cd st
apt-get install -y pkg-config > /dev/null 2>&1
apt install libxft-dev -y  > /dev/null 2>&1
make install  > /dev/null 2>&1
echo -e "*.alpha: 0.9\n*.font: Liberation Mono:pixelsize=18" > ~/.Xdefaults

#Setup Empire
echo "Installing Empire... $red (2/6) $white"
cd ~
git clone https://github.com/EmpireProject/Empire -b dev  > /dev/null 2>&1
cd Empire
./setup/install.sh  > /dev/null 2>&1 #Hangs during install while asking for server encryption key -- enter one or just press enter to continue


#Setup Fish
echo "Installing Fish... $red (3/6) $white"
wget -q https://download.opensuse.org/repositories/shells:fish:release:2/Debian_8.0/Release.key -O - | apt-key add -
apt update  > /dev/null 2>&1
apt install -y fish  > /dev/null 2>&1
chsh -s `which fish`  > /dev/null 2>&1


#Setup gdb-peda
echo "Installing gdb-peda... $red (4/6) $white"
git clone https://github.com/longld/peda.git ~/peda  > /dev/null 2>&1
echo "source ~/peda/peda.py" >> ~/.gdbinit 

#Setup CME
echo "Installing CME..."
cd ~
apt install -y libssl-dev libffi-dev python-dev build-essential python-pip > /dev/null 2>&1
pip install pipenv > /dev/null 2>&1
git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec > /dev/null 2>&1
cd CrackMapExec
pipenv install > /dev/null 2>&1
pipenv run python setup.py install > /dev/null 2>&1

#Various Packages
echo "Installing various packages... $red (5/6) $white"
apt-get install -y screenfetch feh lxappearance gtk-chtheme i3 i3blocks  > /dev/null 2>&1



#Setup dotfiles
echo "Copying over dotfiles... $red (6/6) $white"
mkdir -p ~/.config/  #Incase directory doesn't exist yet
cp -r ~/auto-kali/dotfiles/* ~/.config/. #Copies any dotfiles I have over to .config

echo "All done!"
echo "Going down for a reboot!"
sleep 5
reboot


