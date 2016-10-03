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
if [ "$STEAM" = '1' ]; then

    steam_runtime_file="steam.tar.bz2"
    cd steam-runtime
    # Remove old runtime build
    rm -rf steam

    python2 build-runtime.py
    mv runtime steam
    cd steam
    rm -rf runtime
    rm -rf amd64/lib/x86_64-linux-gnu/libgcc_s.so.1
    rm -rf amd64/lib/x86_64-linux-gnu/libglib-2.0.so.0*
    rm -rf amd64/lib/x86_64-linux-gnu/libgpg-error.so.0*
    rm -rf amd64/lib/x86_64-linux-gnu/libpcre.so.*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/gio
    rm -rf amd64/usr/lib/x86_64-linux-gnu/glib-2.0
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libSDL-1.2.so.0*
    # rm -rf amd64/usr/lib/x86_64-linux-gnu/libX11-xcb.so*
    # rm -rf amd64/usr/lib/x86_64-linux-gnu/libX11.so*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libatk-1.0.so.0*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libcairo.so.2*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libfontconfig.so*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libgio-2.0.so*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libgmodule-2.0.so*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libgobject-2.0.so*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libgthread-2.0.so*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libgomp.so.1*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libstdc++.so.6*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libncurses*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libtinfo*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libtdb.so*
    rm -rf amd64/usr/lib/x86_64-linux-gnu/libxml2.so*
    rm -rf amd64/usr/share/doc
    rm -rf amd64/usr/share/glib-2.0
    rm -rf i386/lib/i386-linux-gnu/libgcc_s.so.1
    rm -rf i386/lib/i386-linux-gnu/libglib-2.0.so.0*
    rm -rf i386/lib/i386-linux-gnu/libgpg-error.so.0*
    rm -rf i386/lib/i386-linux-gnu/libpcre.so*
    rm -rf i386/usr/lib/i386-linux-gnu/gio
    rm -rf i386/usr/lib/i386-linux-gnu/glib-2.0
    rm -rf i386/usr/lib/i386-linux-gnu/libSDL-1.2.so.0*
    # rm -rf i386/usr/lib/i386-linux-gnu/libX11-xcb.so*
    # rm -rf i386/usr/lib/i386-linux-gnu/libX11.so*
    rm -rf i386/usr/lib/i386-linux-gnu/libatk-1.0.so.0*
    rm -rf i386/usr/lib/i386-linux-gnu/libcairo.so.2*
    rm -rf i386/usr/lib/i386-linux-gnu/libfontconfig.so*
    rm -rf i386/usr/lib/i386-linux-gnu/libgio-2.0.so*
    rm -rf i386/usr/lib/i386-linux-gnu/libgmodule-2.0.so*
    rm -rf i386/usr/lib/i386-linux-gnu/libgobject-2.0.so*
    rm -rf i386/usr/lib/i386-linux-gnu/libgthread-2.0.so*
    rm -rf i386/usr/lib/i386-linux-gnu/libgomp.so.1*
    rm -rf i386/usr/lib/i386-linux-gnu/libstdc++.so.6*
    rm -rf i386/usr/lib/i386-linux-gnu/libncurses*
    rm -rf i386/usr/lib/i386-linux-gnu/libtinfo*
    rm -rf i386/usr/lib/i386-linux-gnu/libtdb.so*
    rm -rf i386/usr/lib/i386-linux-gnu/libxml2.so*
    rm -rf i386/usr/share/doc
    rm -rf i386/usr/share/glib-2.0
    cd ..

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

