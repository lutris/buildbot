#!/bin/bash

set -e

root_dir=$(pwd)
sourcedir="${root_dir}/wine-src"
builddir="${root_dir}/wine"
version="1.7.39"
arch=$(uname -m)

destdir="${version}-${arch}"

if [ -d ${sourcedir} ]; then
    cd ${sourcedir}
    git checkout master
    git pull
else
    git clone git://source.winehq.org/git/wine.git $sourcedir
    cd $sourcedir
fi
git checkout -b wine-${version}

mkdir $builddir
cd $builddir
$sourcedir/configure --prefix=${installdir}/${destdir}
make -j4
make install

cd ${root_dir}
find . -type f -exec strip {} \;
tar cvzf wine-${version}-${arch}.tar.gz ${destdir}
rm -rf ${builddir} ${source_dir}
