#!/bin/bash

sudo apt-get install -y libgl1-mesa-dev:i386 libxrandr-dev:i386

git clone git@github.com:xLAva/JediOutcastLinux.git

mkdir build
cd build
cmake ../JediOutcastLinux
make
strip jk2sp
strip jk2gamex86.so
tar cvzf jedi-outcast-i386.tar.gz jk2gamex86.so jk2sp
