#!/bin/bash

if [[ "$(uname -m)" == "i686" ]]; then
    arch="32"
    steam_rt="i386"
else
    arch="64"
    steam_rt="amd64"
fi

sudo python2 lutrisrt.py
sudo chown $(id -u):$(id -g) runtime -R

cd steam-runtime
python2 build-runtime.py
cd ..

runtime_root="runtime${arch}"

mkdir -p ${runtime_root}
mkdir -p ${runtime_root}
cp -r steam-runtime/runtime/${steam_rt}/* ${runtime_root}
mv runtime ${runtime_root}/lib${arch}
cp extra/lib${arch}/* ${runtime_root}/lib${arch}

tar cjf ${runtime_root}.tar.bz2 ${runtime_root}
rm -rf ${runtime_root}
