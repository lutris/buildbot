#!/bin/bash

set -e

source ../../lib/util.sh

version="0.4.17.1"
arch=$(uname -m)
root_dir=$(pwd)
pkg_name="minetest"
src_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

InstallBuildDependencies() {
    install_deps build-essential libirrlicht-dev cmake libbz2-dev libpng-dev libjpeg-dev \
        libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev \
        libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev
}

GetSources() {
    cd "$root_dir"
    git clone https://github.com/minetest/minetest.git "$src_dir"
    cd "$src_dir"
    git checkout stable-0.4
    git clone --depth 1 https://github.com/minetest/minetest_game.git games/minetest_game
}

Build() {
    cd "$src_dir"
    cmake . -DRUN_IN_PLACE=TRUE
    make -j 8
}

Package() {
    cd "$root_dir"
    mkdir -p "$bin_dir"
    cp -a "${src_dir}/bin" "$bin_dir"
    cp -a "${src_dir}/builtin" "$bin_dir"
    cp -a "${src_dir}/client" "$bin_dir"
    cp -a "${src_dir}/clientmods" "$bin_dir"
    cp -a "${src_dir}/doc" "$bin_dir"
    cp -a "${src_dir}/fonts" "$bin_dir"
    cp -a "${src_dir}/games" "$bin_dir"
    cp -a "${src_dir}/misc" "$bin_dir"
    cp -a "${src_dir}/mods" "$bin_dir"
    cp -a "${src_dir}/po" "$bin_dir"
    cp -a "${src_dir}/textures" "$bin_dir"
    cp -a "${src_dir}/util" "$bin_dir"
    cp "${src_dir}/minetest.conf.example" "$bin_dir"
    cp "${src_dir}/minetest.conf.example.extra" "$bin_dir"
    cp "${src_dir}/README.txt" "$bin_dir"
    tar czf "${pkg_name}-${version}-${arch}.tar.gz" "${pkg_name}"
}

Clean() {
    cd "${root_dir}"
    rm -rf "${bin_dir}"
    rm -rf "${src_dir}"
}

if [ "$1" ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
    Clean
fi
