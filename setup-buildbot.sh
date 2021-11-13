#!/bin/bash

set -e

apt update
apt -y full-upgrade
apt -y install software-properties-common

# for sdl2 support
add-apt-repository ppa:cybermax-dexter/sdl2-backport -y

# for vkd3d support
add-apt-repository ppa:cybermax-dexter/vkd3d -y

# for gcc 11
add-apt-repository ppa:ubuntu-toolchain-r/test -y

apt update

apt -y install wget curl build-essential git python openssh-server s3cmd awscli vim zsh fontconfig sshpass gcc-11 g++-11

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11

#Install MinGW
cd ~
if [ "$(uname -m)" = "x86_64" ]; then
    wget https://github.com/lutris/mostlyportable-gcc/releases/download/mingw-11.2.1/mingw-mostlyportable-11.2.1-64.tar.xz
    tar xf ~/mingw-mostlyportable-11.2.1-64.tar.xz
    mv ~/mingw-mostlyportable-11.2.1-64 /opt/mingw-mostlyportable
    rm ~/mingw-mostlyportable-11.2.1-64.tar.xz
else
    wget https://github.com/lutris/mostlyportable-gcc/releases/download/mingw-11.2.1/mingw-mostlyportable-11.2.1-32.tar.xz
    tar xf ~/mingw-mostlyportable-11.2.1-32.tar.xz
    mv ~/mingw-mostlyportable-11.2.1-32 /opt/mingw-mostlyportable
    rm ~/mingw-mostlyportable-11.2.1-32.tar.xz
fi
sed -i s#'PATH="'#'PATH="/opt/mingw-mostlyportable/strip:/opt/mingw-mostlyportable/bin:/opt/mingw-mostlyportable/lib:'#g /etc/environment

# Install Doctl
wget https://github.com/digitalocean/doctl/releases/download/v1.62.0/doctl-1.62.0-linux-amd64.tar.gz
tar xf ~/doctl-1.62.0-linux-amd64.tar.gz
mv ~/doctl /usr/local/bin
rm doctl-1.62.0-linux-amd64.tar.gz
