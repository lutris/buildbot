#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="winetricks"
version="master"
arch=$(uname -m)
root_dir=$(pwd)
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"


GetSources() {
    filename="${version}.tar.gz"
    wget https://github.com/Winetricks/winetricks/archive/${filename}
    tar xzf ${filename}
    rm ${filename}
    mv winetricks-${version} "${source_dir}"
}

BuildProject() {
    cd "${source_dir}"

    # Fix language bug on unattended dotnet462 install
    sed -i 's/WINEDLLOVERRIDES=fusion=b "$WINE" "$file_package" ${W_OPT_UNATTENDED:+$unattended_args}/WINEDLLOVERRIDES=fusion=b "$WINE" "$file_package" \/sfxlang:1027 ${W_OPT_UNATTENDED:+$unattended_args}/g' src/winetricks

    # dotnet471 support, 64-bit mostly working	
    patch -Np1 < ../'patches/dotnet471.patch'
    
    mkdir -p "${bin_dir}"
    cp "${source_dir}/src/winetricks" "${bin_dir}"
}


PackageProject() {
    cd "$root_dir"
    tar czf "${pkg_name}-${version}-${arch}.tar.gz" "${pkg_name}"
}

Cleanup() {
    cd "$root_dir"
    rm -rf "$bin_dir"
    rm -rf "$source_dir"
}


if [ "$1" ]; then
    $1
else
    GetSources $version
    BuildProject
    PackageProject
    # Cleanup
fi
