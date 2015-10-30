#!/bin/bash

sudo apt-get install elfutils libelf-dev linux-headers-generic linux-libc-dev

mkdir -p lib

git clone https://github.com/nwnlinux/nwlogger.git
cd nwlogger
sed -i -e "s%linux/user.h%sys/user.h%" nwlogger/nwlogger_cookie.c
./nwlogger_install.pl
cp nwlogger/nwlogger.so ../lib
cd ..

git clone https://github.com/nwnlinux/nwmovies.git
cd nwmovies
./nwmovies_install.pl
cp nwmovies/binklib.so nwmovies/nwmovies.so ../lib
cd ..

git clone https://github.com/nwnlinux/nwuser.git
cd nwuser
./nwuser_install.pl
cp nwuser/nwuser.so ../lib
cd ..

git clone https://github.com/nwnlinux/nwmouse.git
cd nwmouse
cp mwmouse/nwmouse.so ../lib
./nwmouse_install.pl
