#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

params=$(getopt -n $0 -o egd --long ece,glide,dependencies -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -e|--ece) ECE=1; shift ;;
        -g|--glide) GLIDE=1; shift ;;
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        *) shift; break ;;
    esac
done

if [ $ECE ]; then
    filename_opts="-ece"
elif [ $GLIDE ]; then
    filename_opts="-glide"
fi

runner_name="$(get_runner)"
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
dosbox_ece_revision=4280
arch=$(uname -m)


InstallDeps() {
    deps="libsdl-sound1.2-dev libsdl1.2-dev libpng-dev libsdl-net1.2-dev libasound2-dev autotools-dev"
    install_deps $deps
    if [ $ECE ]; then
        install_deps "p7zip-full"

        # Install mt32 lib
        cd $root_dir
        clone https://github.com/munt/munt.git munt
        cd ${root_dir}/munt/mt32emu
        cmake -DCMAKE_BUILD_TYPE:STRING=Release .
        make
        sudo make install
    else
        install_deps "subversion"
    fi
    if [[ $GLIDE || $ECE ]]; then
        cd $root_dir
        clone https://github.com/voyageur/openglide openglide
        cd ${root_dir}/openglide
        ./bootstrap
        ./configure --prefix=/usr
        make
        sudo make install
    fi
}

GetSources() {
    if [ $ECE ]; then
        wget "https://dosboxdl.yesterplay.net/DOSBox%20ECE%20r${dosbox_ece_revision}%20(Linux%20source).7z"
        mkdir -p ${source_dir}
        7z x "DOSBox ECE r${dosbox_ece_revision} (Linux source).7z" -o${source_dir}
        rm "DOSBox ECE r${dosbox_ece_revision} (Linux source).7z"
    else
        svn checkout svn://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk ${source_dir}
    fi
}

BuildDosbox() {
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
    if [ $ECE ]; then
        version=$dosbox_ece_revision
    else
        version=$(svn info | grep "^Revision" | cut -d" " -f 2)
    fi
    cd ${root_dir}
    dest_file="${runner_name}${filename_opts}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
    runner_upload dosbox ${version}${filename_opts} ${arch} ${dest_file}
}

if [ $INSTALL_DEPS ]; then
    InstallDeps
fi

GetSources
BuildDosbox
PackageDosbox
