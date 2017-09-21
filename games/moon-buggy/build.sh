 
#!/bin/bash

set -e

source ../../lib/util.sh

version="2.0"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="moon-buggy"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"


InstallBuildDependencies() {
    install_deps libncurses5-dev
}

GetSources() {
    cd $root_dir
    clone https://github.com/mike-teehan/moon-buggy $source_dir
}

Build() {
    cd $source_dir
    mkdir -p build
    cd build
    cmake ..
    make -j4
}

Package() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp $source_dir/build/bin/moon-buggy $bin_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Clean() {
    cd $root_dir
    rm -rf $bin_dir
    rm -rf $source_dir
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
