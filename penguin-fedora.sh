#!/bin/bash

# define variables
HOMEDIR="/home/$USER"
GITREPO="home/$USER/github-repos"

install_deps() {
  sudo dnf install $1 -y
}

clone_dotsfiles() {
  git clone https://github.com/ArchLinuxChad/dotfiles.git
}

place_dotfiles() {
  cd $GITREPO/dotfiles 
  cp .xinitrc $HOMEDIR
  cp .bashrc $HOMEDIR
  cp .vimrc $HOMEDIR
  cp .bash_profile $HOMEDIR 
  cp -r .config/* $HOMEDIR/.config/
}

clone_scripts() {
  git clone https://github.com/ArchLinuxChad/scripts.git
}

clone_suckless() {
  git clone https://github.com/ArchLinuxChad/dwm.git
  git clone https://github.com/ArchLinuxChad/st.git
  git clone https://github.com/ArchLinuxChad/dmenu.git
}

build_suckless() {
  cd $HOMEDIR/dwm
  sudo make install
  cd $HOMEDIR/st
  sudo make install
  cd $HOMEDIR/dmenu
  sudo make install
}

disk_check() {
  SPACE=$(df -h | grep "/$" | awk '{print $4}' | sed 's/G//')
  [[ "$SPACE" -ln 5 ]] && echo "You do not have enough disk space" && exit 1
}

install_font() {
  cd $HOMEDIR/Downloads
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/SpaceMono.zip
  [[ ! -d $HOMEDIR/.local/share/fonts ]] && mkdir $HOMEDIR/.local/share/fonts
  mv $HOMEDIR/Downloads/SpaceMono.zip $HOMEDIR/.local/share/fonts/
  cd $HOMEDIR/.local/share/fonts
  unzip SpaceMono.zip
  rm OFL.txt
  rm README.md
}

ufw_firewall() {
  sudo systemctl disable firewalld.service --now
  sudo dnf remove firewalld -y
  sudo ufw default allow outgoing
  sudo ufw default deny incoming
  sudo ufw enable
  sudo systemctl enable ufw.service --now
}

# check if there is enough disk space
disk_check

# install depencies
install_deps $(cat progs.txt)

# create and build suckless apps
cd $HOMEDIR
clone_suckless
build_suckless

# if git dierectory does not exist create it
[[ ! -d $HOMEDIR/$GITREPO ]] && mkdir $HOMEDIR/$GITREPO

# clone scripts and dotfile
cd $GITREPO
clone_dotfiles
place_dotfiles
clone_scripts
# place scripts in /usr/local/bin
cd $GITREPO/scripts
./setupscripts.sh &

# install fonts
install_font 

# make ufw firewall
ufw_firewall

# rip out gdm and replace with .xinitrc
sudo systemctl disable gdm.service

# reboot the system
sudo reboot now
