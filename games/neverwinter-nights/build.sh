#!/bin/bash

sudo apt-get install elfutils libelf-dev linux-headers-generic linux-libc-dev

mkdir -p lib

git clone https://github.com/nwnlinux/nwlogger.git
cd nwlogger
./nwlogger_install.pl
cd ..

git clone https://github.com/nwnlinux/nwmovies.git
cd nwmovies
./nwmovies_install.pl
cd ..

git clone https://github.com/nwnlinux/nwuser.git
cd nwuser
./nwuser_install.pl
cd ..

git clone https://github.com/nwnlinux/nwmouse.git
cd nwmouse
./nwmouse_install.pl
