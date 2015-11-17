#!/bin/bash

set -e
lib_path="../lib/"
source ${lib_path}upload_handler.sh

arch=$(uname -m)
if [[ "$arch" == "i686" ]]; then
    bit="32"
else
    bit="64"
fi
runtime_dir="lib${bit}"

# Steam runtime
# Only build steam runtime once since it contains both archs
if [ '$STEAM' = '1' ]; then
    steam_runtime_file="steam.tar.bz2"
    cd steam-runtime
    python2 build-runtime.py
    mv runtime steam
    tar cjf $steam_runtime_file steam
    mv $steam_runtime_file ..
    cd ..
    runtime_upload steam $steam_runtime_file
    exit 0
fi

# Lutris runtime
mkdir -p ${runtime_dir}
sudo python2 lutrisrt.py
sudo chown $(id -u):$(id -g) runtime -R
cp -a runtime/* ${runtime_dir}

# Copy Lutris runtime extra libs
cp -a extra/${runtime_dir}/* ${runtime_dir}

runtime_archive="${runtime_dir}.tar.bz2"
tar cjf ${runtime_archive} ${runtime_dir}
runtime_upload ${runtime_dir} ${runtime_archive}

