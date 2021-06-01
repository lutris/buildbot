#!/bin/bash

set -e

apt update
apt -y full-upgrade
apt -y install software-properties-common
add-apt-repository ppa:cybermax-dexter/sdl2-backport -y
add-apt-repository ppa:cybermax-dexter/vkd3d -y
apt update
apt -y install wget curl build-essential git python openssh-server s3cmd awscli vim zsh fontconfig sshpass

# Install Doctl
cd ~
wget https://github.com/digitalocean/doctl/releases/download/v1.60.0/doctl-1.60.0-linux-amd64.tar.gz
tar xf ~/doctl-1.60.0-linux-amd64.tar.gz
sudo mv ~/doctl /usr/local/bin