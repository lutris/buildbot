#!/bin/bash

set -e

source ../../lib/util.sh

version="0.9.3-net"
arch=$(uname -m)
root_dir=$(pwd)
pkg_name="SuperTuxKart"
build_dir="${root_dir}/${pkg_name}-build"
src_dir="${build_dir}/stk-code"
asset_dir="${build_dir}/stk-assets"
bin_dir="${root_dir}/${pkg_name}"
package_libraries="libenet libcurl"

InstallBuildDependencies() {
    install_deps build-essential cmake libbluetooth-dev \
        libcurl4-openssl-dev libenet-dev libfreetype6-dev libfribidi-dev \
        libgl1-mesa-dev libglew-dev libjpeg-dev libogg-dev libopenal-dev libpng-dev \
        libssl-dev libvorbis-dev libxrandr-dev libx11-dev pkg-config zlib1g-dev subversion
}

GetSources() {
    cd $root_dir
    clone https://github.com/supertuxkart/stk-code.git "${src_dir}"
    # don't redownload the assets if they seem to exist, ie CACHE file exists
    if [ ! -d "${asset_dir}" ]; then
        svn co https://svn.code.sf.net/p/supertuxkart/code/stk-assets "${asset_dir}"
    fi
}

Build() {
    cd "${src_dir}"
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="${bin_dir}"
    make -j $((($(cat /proc/cpuinfo | egrep ^processor | wc -l) +1)))
    make install
}

Package() {
    cd $root_dir
    cp run_game.sh ${bin_dir}
    chmod +x "${bin_dir}/run_game.sh"
    LIB_DIR="${bin_dir}/lib"
    mkdir "${LIB_DIR}"
    for LIB in $package_libraries; do
        LIB_FILE=$(ldd "${bin_dir}/bin/supertuxkart" | grep "${LIB}.so" | awk '{print $3;}')
        cp "${LIB_FILE}" "${LIB_DIR}"
    done
    tar czf "${pkg_name}-${version}-${arch}.tar.gz" "${pkg_name}"
}

Clean() {
    cd "${root_dir}"
    rm -rf "${bin_dir}"
    # '$ touch CACHE' to not delete the assets and reuse them
    if [ ! -f "CACHE" ]; then
        rm -rf "${build_dir}"
    else
        rm -rf "${src_dir}"
    fi
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
    Clean
fi
