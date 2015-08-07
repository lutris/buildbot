#!/bin/bash

set -e

rootdir=$(pwd)
builddir=${rootdir}/rigs-of-rods
sourcedir=${rootdir}/rigs-of-rods-src
depsdir=${rootdir}/rigs-of-rods-deps

PKG_CONFIG_PATH="${builddir}/lib/pkgconfig"
make_opts="-j4"
export PKG_CONFIG_PATH

sudo apt-get update
sudo apt-get -q install subversion mercurial build-essential git cmake \
    pkg-config libboost-all-dev libfreetype6-dev libfreeimage-dev libzzip-dev \
    libois-dev libgl1-mesa-dev libglu1-mesa-dev nvidia-cg-toolkit libopenal-dev \
    libx11-dev libxt-dev libxaw7-dev libxrandr-dev libssl-dev \
    libcurl4-openssl-dev libgtk2.0-dev libwxgtk3.0-dev libasound2-dev \
    libpulse-dev wget automake pkg-config doxygen scons libxxf86vm-dev uuid-dev \
    libuuid1

mkdir -p ${depsdir}
cd ${depsdir}

# OGRE
hg clone https://bitbucket.org/sinbad/ogre -b v1-8
cd ogre
cmake -DCMAKE_INSTALL_PREFIX="${builddir}" \
    -DFREETYPE_INCLUDE_DIR=/usr/include/freetype2/ \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DOGRE_BUILD_SAMPLES:BOOL=OFF .
make $make_opts
make install

# OIS (Fails to build)

#svn co https://wgois.svn.sourceforge.net/svnroot/wgois/ois/trunk/ ois-trunk
#cd ois-trunk
#bash bootstrap
#./configure
#make -j2
#sudo make install
#cd ..

# OpenAL
cd "${depsdir}"
wget -c http://kcat.strangesoft.net/openal-releases/openal-soft-1.16.0.tar.bz2
tar -xvjf openal-soft-1.16.0.tar.bz2
cd openal-soft-1.16.0
cmake -DCMAKE_INSTALL_PREFIX="${builddir}" .
make $make_opts
make install

# MyGUI
cd "${depsdir}"
wget -c -O mygui.zip https://github.com/MyGUI/mygui/archive/a790944c344c686805d074d7fc1d7fc13df98c37.zip
unzip -o mygui.zip
cd mygui-*
cmake -DCMAKE_INSTALL_PREFIX="$builddir" \
    -DFREETYPE_INCLUDE_DIR=/usr/include/freetype2/ \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DMYGUI_BUILD_DEMOS:BOOL=OFF \
    -DMYGUI_BUILD_DOCS:BOOL=OFF \
    -DMYGUI_BUILD_TEST_APP:BOOL=OFF \
    -DMYGUI_BUILD_TOOLS:BOOL=OFF \
    -DMYGUI_BUILD_PLUGINS:BOOL=OFF .
make $make_opts
make install

# Paged geometry
cd "${depsdir}"
if [ ! -e ogre-paged ]; then
    git clone --depth=1 https://github.com/Hiradur/ogre-paged.git
    cd ogre-paged
else
    cd ogre-paged
    git pull
fi

cmake -DCMAKE_INSTALL_PREFIX="$builddir" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DPAGEDGEOMETRY_BUILD_SAMPLES:BOOL=OFF .
make $make_opts
make install
cd ..

# Caelum
cd "${depsdir}"
wget -c -O caelum.zip http://caelum.googlecode.com/archive/3b0f1afccf5cb75c65d812d0361cce61b0e82e52.zip
unzip -o caelum.zip
cd caelum-*
cmake -DCMAKE_INSTALL_PREFIX="${builddir}" \
    -DCaelum_BUILD_SAMPLES:BOOL=OFF .
make ${make_opts}
make install
# important step, so the plugin can load:
ln -s ${builddir}/lib/libCaelum.so ${builddir}/lib/OGRE/

# MySocketW
cd ${depsdir}
if [ ! -e mysocketw ]; then
  git clone --depth=1 https://github.com/Hiradur/mysocketw.git
fi
cd mysocketw
git pull
make ${make_opts} shared
PREFIX="${builddir}" make install

# AngelScript
mkdir -p angelscript
cd angelscript
wget -c http://www.angelcode.com/angelscript/sdk/files/angelscript_2.22.1.zip
unzip -o angelscript_*.zip
cd sdk/angelscript/projects/gnuc
sed -i '/^LOCAL *=/d' makefile
# make fails when making the symbolic link, this removes the existing versions
rm -f ../../lib/*
SHARED=1 VERSION=2.22.1 make ${make_opts}
rm -f ../../lib/*
SHARED=1 VERSION=2.22.1 LOCAL="${builddir}" make -s install

cd $rootdir

if [ ! -e $sourcedir ]; then
    git clone https://github.com/RigsOfRods/rigs-of-rods.git $sourcedir
    cd ${sourcedir}
else
    cd ${sourcedir}
    git pull
fi

cmake \
    -DCMAKE_INSTALL_PREFIX="${builddir}" \
    -DROR_USE_MYGUI="TRUE" \
    -DROR_USE_OPENAL="TRUE" \
    -DROR_USE_SOCKETW="TRUE" \
    -DROR_USE_PAGED="TRUE" \
    -DROR_USE_CAELUM="TRUE" \
    -DROR_USE_ANGELSCRIPT="TRUE" \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_CXX_FLAGS="-pipe -march=native" \
    .

make ${make_opts}

sed -i '/^PluginFolder=/d' bin/plugins.cfg
echo "PluginFolder=${builddir}/lib/OGRE" >>bin/plugins.cfg

cp -R bin "${builddir}"

cd ${builddir}
mkdir -p packs

wget http://www.rigsofrods.com/repository/viewTag/id:981/download:1 -O content-pack-0.4.zip
unzip content-pack-0.4.zip -d packs/
mv packs/ContentPack04/* -t packs/
rmdir packs/ContentPack04

wget http://www.rigsofrods.com/repository/viewTag/id:982/download:1 -O hq-pack-0.4.zip
unzip hq-pack-0.4.zip -d packs/
mv HighQuality04/* -t packs/
rmdir packs/HighQuality04
