#!/bin/bash

apt-get install -y curl wget unzip debhelper \
    libexpat1-dev libflac-dev libfontconfig1-dev \
    libjpeg8-dev libportmidi-dev libqt4-dev libsdl2-ttf-dev \
    libsdl2-dev libxinerama-dev subversion python-dev zlib1g-dev
release=$(curl http://mamedev.org/release.html | grep "href.*s.zip" | cut -d"\"" -f 2)
archive=$(echo ${release} | cut -d"/" -f 2)
wget "http://mamedev.org/${release}" -O ${archive}
unzip -o $archive
unzip -o mame.zip

unset FULLNAME
make
TARGET=mess make
