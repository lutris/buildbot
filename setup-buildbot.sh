#!/bin/bash

set -e

apt update
apt -y full-upgrade
apt -y install software-properties-common

# for sdl2 support
add-apt-repository ppa:cybermax-dexter/sdl2-backport -y

# for vkd3d support
add-apt-repository ppa:cybermax-dexter/vkd3d -y

# for latest mingw
add-apt-repository ppa:cybermax-dexter/mingw-w64-backport -y

apt update
apt -y install wget curl build-essential git python openssh-server s3cmd awscli vim zsh fontconfig sshpass gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 g++-mingw-w64-i686 g++-mingw-w64-x86-64

# Install Doctl
cd ~
wget https://github.com/digitalocean/doctl/releases/download/v1.60.0/doctl-1.60.0-linux-amd64.tar.gz
tar xf ~/doctl-1.60.0-linux-amd64.tar.gz
sudo mv ~/doctl /usr/local/bin
