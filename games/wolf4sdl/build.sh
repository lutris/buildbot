#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=1.7
arch=$(uname -m)
source_dir=${root_dir}/wolf4sdl-src
execname=wolf3d

params=$(getopt -n $0 -o s --long spear -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -s|--spear) spear=1; shift ;;
        *) shift; break ;;
    esac
done

clone https://github.com/ljbade/wolf4sdl.git $source_dir
cd $source_dir

if [ "$spear" ]; then
    sed -i '/define SPEAR$/s/\/\///' version.h
    execname=spear
fi

DATADIR= make
if [ $execname != 'wolf3d' ]; then
    mv wolf3d $execname
fi

tar czf ../wolf4sdl-${execname}-${version}-${arch}.tar.gz $execname
cd ..
rm -rf $source_dir
