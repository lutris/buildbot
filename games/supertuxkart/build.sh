#!/bin/bash

set -e

source ../../lib/util.sh

version="0.9.3-net"
arch=$(uname -m)
root_dir=$(pwd)
pkg_name="SuperTuxKart"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"
package_libraries="libenet"

InstallBuildDependencies() {
    install_deps build-essential cmake libbluetooth-dev \
        libcurl4-openssl-dev libenet-dev libfreetype6-dev libfribidi-dev \
        libgl1-mesa-dev libglew-dev libjpeg-dev libogg-dev libopenal-dev libpng-dev \
        libssl-dev libvorbis-dev libxrandr-dev libx11-dev pkg-config zlib1g-dev subversion
}

GetSources() {
    cd $root_dir
    clone https://github.com/supertuxkart/stk-code.git "${source_dir}/stk-code"
    svn co https://svn.code.sf.net/p/supertuxkart/code/stk-assets "${source_dir}/stk-assets"
}

Build() {
    cd "${source_dir}/stk-code"
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="${bin_dir}"
    make -j$(getconf _NPROCESSORS_ONLN)
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
    rm -rf "${source_dir}"
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
