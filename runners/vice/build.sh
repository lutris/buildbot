#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
bin_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
source_dir="${runner_name}-src"

InstallBuildDependencies() {
    deps="libxxf86vm-dev libxmu-dev libxaw7-dev libreadline-dev texinfo xfonts-utils"
    install_deps $deps
}

GetSources() {
    #src_archive="${source_dir}.tar.gz"
    #src_url="http://sourceforge.net/projects/vice-emu/files/releases/${src_archive}/download"
    #wget ${src_url} -O ${src_archive}
    #tar xzf ${src_archive}
    svn checkout svn://svn.code.sf.net/p/vice-emu/code/trunk ${source_dir}
    cd $source_dir
    version="r$(svn info | grep "^Revision:" | cut -d" " -f 2)"
}

BuildProject() {
    cd ${source_dir}/vice
    ./autogen.sh
    ./configure --enable-sdlui2 --prefix=${bin_dir}
    make
    make install
}

PackageProject() {
    cd $root_dir
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
}

Cleanup() {
    rm -rf ${source_dir} ${bin_dir}
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
fi
