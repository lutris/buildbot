#!/bin/bash

set -e

root_dir="$(pwd)"

wine_path="wine-git"
wine_staging_path="wine-staging"
wine_pba_path="wine-pba"
wine_version="3.3"

cd $wine_path
git clean -df
git reset --hard
git fetch
git checkout wine-$wine_version

cd $root_dir
cd $wine_staging_path
git fetch
git checkout v$wine_version

cd $root_dir
./$wine_staging_path/patches/patchinstall.sh  DESTDIR="$root_dir/$wine_path" --all

cd $root_dir
cd $wine_pba_path
git pull

cd $root_dir
cd $wine_path
for patchfile in $(ls ../${wine_pba_path}/patches); do
    patch -p1 < ../${wine_pba_path}/patches/$patchfile;
done

cd $root_dir
mv $wine_path "wine-$wine_version"
tar cJvf wine-$wine_version.tar.xz --exclude wine-$wine_version/.git wine-$wine_version
mv "wine-$wine_version" $wine_path

lxc file push wine-$wine_version.tar.xz buildbot-xenial-amd64/home/ubuntu/buildbot/runners/wine/.cache/wine-$wine_version.tar.xz
lxc file push wine-$wine_version.tar.xz buildbot-xenial-i386/home/ubuntu/buildbot/runners/wine/.cache/wine-$wine_version.tar.xz
