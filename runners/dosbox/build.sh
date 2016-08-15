#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

params=$(getopt -n $0 -o gd --long glide,dependencies -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -g|--glide) GLIDE=1; shift ;;
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        *) shift; break ;;
    esac
done

if [ $GLIDE ]; then
    filename_opts="-glide"
fi

runner_name="$(get_runner)${filename_opts}"
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)


InstallDeps() {
    deps="subversion"
    install_deps $deps
    if [ $GLIDE ]; then
        cd $root_dir
        clone https://github.com/voyageur/openglide openglide
        cd ${root_dir}/openglide
        ./bootstrap
        ./configure --prefix=/usr
        make
        sudo make install
    fi
}

BuildDosbox() {
    svn checkout svn://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk ${source_dir}
    mkdir -p "${build_dir}"
    cd $source_dir
    ./autogen.sh
    if [ $GLIDE ]; then
        patch -p0 < ../dosbox_glide.diff
    fi
    ./configure --prefix="${build_dir}"
    make
    make install
}

PackageDosbox() {
    revision=$(svn info | grep "^Revision" | cut -d" " -f 2)
    version="svn${revision}"
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
    runner_upload dosbox ${version}${filename_opts} ${arch} ${dest_file}
}

if [ $INSTALL_DEPS ]; then
    InstallDeps
fi

BuildDosbox
PackageDosbox
