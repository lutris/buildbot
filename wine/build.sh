#!/bin/bash

sourcedir="$HOME/wine-git"
builddir="$HOME/wine32"
installdir="/opt"
version="1.7.38"
arch="i386"

destdir="${version}-${arch}"

cd $sourcedir
git co master
git pull
git co -b wine-${version}

rm -rf "$builddir"
mkdir $builddir
cd $builddir
$sourcedir/configure --prefix=${installdir}/${destdir}
make -j4
make install

cd $installdir
find . -type f -exec strip {} \;
tar cvzf wine-${version}-${arch}.tar.gz ${destdir}
