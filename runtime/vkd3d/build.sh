#!/bin/bash

set -e

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${root_dir}

#lib_path="../../lib/"
#source ${lib_path}path.sh
#source ${lib_path}util.sh
#source ${lib_path}upload_handler.sh

buildbot32host="buildbot32"
buildbot64host="buildbot64"
date=$(date '+%Y%m%d')
source_dir="${root_dir}/vkd3d-src"
build_dir="${root_dir}/vkd3d-build"
lib_dir="${root_dir}/vkd3d-lib"
arch=$(uname -m)
branch_name="master"
repo_url="https://github.com/HansKristian-Work/vkd3d.git"

params=$(getopt -n $0 -o b:r: --long branch:,repo: -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -b|--branch) branch_name=$2; shift 2 ;;
        -r|--repo) repo_url=$2; shift 2 ;;
        *) shift; break ;;
    esac
done

InstallDependencies() {
    sudo apt install -y autoconf bison libtool libvulkan-dev pkgconf spirv-headers vulkan-headers winehq-widl
}

Download() {
    if [ -d "$source_dir" ]; then
        cd $source_dir
        if [ $(git branch -v | grep -o "$branch_name ") ]; then
            git branch -m "$branch_name" "$branch_name"-old
        fi
        git fetch $repo_url $branch_name:$branch_name
        git checkout $branch_name
        if [ $(git branch -v | grep -o "$branch_name-old ") ]; then
            git branch -D "$branch_name"-old
        fi
    else
        git clone -b $branch_name $repo_url $source_dir
        cd $source_dir
    fi

    commit_id=$(git rev-parse --short HEAD)
}

BuildVKD3D() {
    mkdir -p $build_dir
    mkdir -p $lib_dir
    
    cd $source_dir
    $source_dir/autogen.sh
    
    cd $build_dir
    CPPFLAGS="-DNDEBUG -DVKD3D_NO_TRACE_MESSAGES -DVKD3D_NO_DEBUG_MESSAGES" $source_dir/configure --prefix=$build_dir --libdir=$lib_dir
    
    make -j$(getconf _NPROCESSORS_ONLN) install-strip
    find $lib_dir -name \*.la -type f -delete
    find $lib_dir -name \*.a -type f -delete
    rm -rf "$lib_dir/pkgconfig"

    if [ $arch = "x86_64" ]; then
        mv ${lib_dir} $root_dir/lib64
    else
        mv ${lib_dir} $root_dir/lib32
    fi
}

Build32bit() {
    cd ${root_dir}

    echo "Building 32bit VKD3D"
    opts=""
    opts="${opts} --repo $repo_url"
    opts="${opts} --branch $branch_name"

    echo "Building 32bit Vkd3d on 32bit container"
    ssh -t ${buildbot32host} "${root_dir}/build.sh ${opts}"
}

Send32bitLibs() {
    cd ${root_dir}
    tar -cf "${root_dir}/vkd3d-libs-32.tar" lib32
    lib32="${root_dir}/vkd3d-libs-32.tar"
    scp ${lib32} ${buildbot64host}:${root_dir}
}

Package() {
    cd ${root_dir}
    lib32="${root_dir}/vkd3d-libs-32.tar"
    dest_file="$root_dir/vkd3d-libs-$date-$commit_id.tar"

    if [ -f $dest_file ]; then
        rm $dest_file
    fi

    mv $lib32 $dest_file
    tar -rf $dest_file lib64
    echo "Build finished."
}

Build() {
    if [[ $arch != "x86_64" && $arch != "i686" ]]; then
        echo "Vkd3d doesn't support non-x86 systems, aborting."
        exit
    fi
    InstallDependencies
    Download
    BuildVKD3D
    if [ $arch = "x86_64" ]; then
        Build32bit
        Package
    else
        Send32bitLibs
    fi
}

Clean() {
    cd ${root_dir}
    rm -rf ${build_dir} ${lib32} ${lib_dir} ${root_dir:?}/lib32 ${root_dir:?}/lib64
}

if [ $1 ]; then
    $1
else
    Build
    Clean
fi

trap Clean EXIT