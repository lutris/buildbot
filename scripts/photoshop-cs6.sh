#!/bin/bash

target_version="1.7.26"
install_dir="/opt/wine"

cd ~/wine-git
git checkout wine-$target_version
export CFLAGS="-fno-stack-protector -mstackrealign -mincoming-stack-boundary=2" 
export CXXFLAGS="-mstackrealign -mincoming-stack-boundary=2"
cd $HOME
mkdir -p wine32
cd wine32
~/wine-git/configure --prefix=$install_dir
make -j4
