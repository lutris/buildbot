#!/bin/bash

lxc_template_dir="/usr/share/lxc/templates"
botname="winebot"
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -e

if [ $(id -u) != 0 ]; then
    echo "Please run this script as root"
    echo "Non root";
    exit 2;
fi

cp lxc-wine $lxc_template_dir
lxc-create -t wine -n $botname -- -a i386 
#--bindhome ${current_dir}/build
