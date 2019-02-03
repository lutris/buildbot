#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="master"
arch="$(uname -m)"

root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"

params=$(getopt -n $0 -o d --long dependencies -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        *) shift; break ;;
    esac
done

InstallBuildDependencies() {
    install_deps libsdl1.2-dev libglew-dev
}

GetSources() {
    repo_url="https://github.com/residualvm/residualvm.git"
    clone $repo_url $source_dir true $version
    cd "${source_dir}"
}

Build() {
    cd $source_dir
    ./configure --prefix=${build_dir} --enable-static --enable-release --enable-all-engines
    make
    make install
}

Package() {
    cd $root_dir
    mkdir -p ${bin_dir}
    mv ${build_dir}/bin/residualvm ${bin_dir}
    mv ${build_dir}/share/residualvm ${bin_dir}/data

    dest_file=${runner_name}-${version}-${arch}.tar.gz
    tar czf ${dest_file} ${runner_name}
}

Upload() {
    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
}

CleanUp() {
    rm -rf ${build_dir} ${source_dir} ${bin_dir}
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
    # Upload
    # CleanUp
fi
