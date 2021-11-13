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
source_dir="${root_dir}/faudio-src"
build_dir="${root_dir}/faudio-build"
lib_dir="$build_dir/lib"
arch=$(uname -m)
repo_url="https://github.com/FNA-XNA/FAudio.git"

params=$(getopt -n $0 -o v:ng: --long version:,nogs: -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -v|--version) version=$2; shift 2 ;;
        -ng|--nogs) NOGS=1; shift ;;
        *) shift; break ;;
    esac
done

InstallDependencies() {
    sudo apt install -y cmake libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x \
        gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio
}

Download() {
    if [ -d "$source_dir" ]; then
        cd $source_dir
        git clean -dfx
        git fetch
        git reset --hard origin/master
    else
        git clone $repo_url $source_dir
        cd $source_dir
    fi
        
    if [ ! $version ]; then
    version=$(git describe --abbrev=0 --tags)
    fi

    git reset --hard $version

}

BuildFAudio() {
    mkdir -p $build_dir
    cd $build_dir

    if [ ! $NOGS ]; then
    GS_STATE="-DGSTREAMER=ON"
    fi

    cmake $GS_STATE -DCMAKE_INSTALL_PREFIX:PATH="$build_dir" $source_dir
    make -j$(getconf _NPROCESSORS_ONLN) install/strip
    rm -rf "$lib_dir/cmake"

    if [ $arch = "x86_64" ]; then
        mv $lib_dir $root_dir/lib64
    else
        mv $lib_dir $root_dir/lib32
    fi
}

Build32bit() {
    cd ${root_dir}

    echo "Building 32bit Faudio"
    opts=""
    opts="--version $version"
    if [ $NOGS ]; then
        opts="${opts} --nogs"
    fi

    echo "Building 32bit Faudio on 32bit container"
    ssh -t ${buildbot32host} "${root_dir}/build.sh ${opts}"
}

Send32bitLibs() {
    cd ${root_dir}
    tar -cf "${root_dir}/faudio-libs-32.tar" lib32
    lib32="${root_dir}/faudio-libs-32.tar"
    scp ${lib32} ${buildbot64host}:${root_dir}
}

Package() {
    cd ${root_dir}
    lib32="${root_dir}/faudio-libs-32.tar"
    dest_file="$root_dir/faudio-libs-$version.tar"

    if [ -f $dest_file ]; then
        rm $dest_file
    fi

    mv $lib32 $dest_file
    tar -rf $dest_file lib64
    echo "Build finished."
}

Build() {
    if [[ $arch != "x86_64" && $arch != "i686" ]]; then
        echo "We don't build Faudio on non-x86 systems, aborting."
        exit
    fi
    InstallDependencies
    Download
    BuildFAudio
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