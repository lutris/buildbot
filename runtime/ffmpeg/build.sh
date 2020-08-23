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
source_dir="${root_dir}/ffmpeg-src"
build_dir="${root_dir}/ffmpeg-build"
arch=$(uname -m)
branch_name="master"
repo_url="https://github.com/FFmpeg/FFmpeg.git"

params=$(getopt -n $0 -o v: --long version: -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -v|--version) version=$2; shift 2 ;;
        *) shift; break ;;
    esac
done

InstallDependencies() {
    sudo apt install -y autoconf bison libtool pkgconf yasm
}

Download() {
    if [ -d "$source_dir" ]; then
        cd $source_dir
        git clean -dfx
        git fetch
        git reset --hard  
    else
        git clone $repo_url $source_dir
        cd $source_dir
    fi
        
    if [ ! $version ]; then
    version=$(git describe --abbrev=0 --tags)
    fi

    git reset --hard $version
}

BuildFFmpeg() {
    mkdir -p $build_dir
    
    cd $source_dir
        ./configure \
            --prefix=$build_dir \
            --disable-static \
            --enable-shared \
            --disable-programs \
            --disable-doc \
            --disable-avdevice \
            --disable-swscale \
            --disable-postproc \
            --disable-alsa \
            --disable-iconv \
            --disable-libxcb_shape \
            --disable-libxcb_shm \
            --disable-libxcb_xfixes \
            --disable-sdl2 \
            --disable-xlib \
            --disable-zlib \
            --disable-bzlib \
            --disable-libxcb \
            --disable-vaapi \
            --disable-vdpau \
            --disable-everything \
            --enable-parser=h264 \
            --enable-decoder=h264 \
            --enable-decoder=mpeg4 \
            --enable-parser=mpegvideo \
            --enable-parser=mpeg4video \
            --enable-parser=mpegaudio \
            --enable-decoder=mpegvideo \
            --enable-decoder=h263 \
            --enable-decoder=wmv1 \
            --enable-decoder=wmv2 \
            --enable-decoder=wmv3 \
            --enable-decoder=wmv3image \
            --enable-decoder=aac \
            --enable-decoder=wmalossless \
            --enable-decoder=wmapro \
            --enable-decoder=wmav1 \
            --enable-decoder=wmav2 \
            --enable-decoder=wmavoice \
            --enable-decoder=adpcm_ms
    
    make -j$(getconf _NPROCESSORS_ONLN) install

    if [ $arch = "x86_64" ]; then
        mv ${build_dir} $root_dir/ffmpeg64
    else
        mv ${build_dir} $root_dir/ffmpeg32
    fi
}

Build32bit() {
    cd ${root_dir}

    echo "Building 32bit FFmpeg"
    opts=""
    opts="${opts} --version $version"

    echo "Building 32bit FFmpeg on 32bit container"
    ssh -t ${buildbot32host} "${root_dir}/build.sh ${opts}"
}

Send32bitLibs() {
    cd ${root_dir}
    tar -cf "${root_dir}/ffmpeg32.tar" ffmpeg32
    ffmpeg32="${root_dir}/ffmpeg32.tar"
    scp ${ffmpeg32} ${buildbot64host}:${root_dir}
}

Package() {
    cd ${root_dir}
    ffmpeg32="${root_dir}/ffmpeg32.tar"
    dest_file="$root_dir/ffmpeg-$version-$date.tar"

    if [ -f $dest_file ]; then
        rm $dest_file
    fi

    mv $ffmpeg32 $dest_file
    tar -rf $dest_file ffmpeg64
    echo "Build finished."
}

Build() {
    if [[ $arch != "x86_64" && $arch != "i686" ]]; then
        echo "We don't build FFmpeg on non-x86 systems, aborting."
        exit
    fi
    InstallDependencies
    Download
    BuildFFmpeg
    if [ $arch = "x86_64" ]; then
        Build32bit
        Package
    else
        Send32bitLibs
    fi
}

Clean() {
    cd ${root_dir}
    rm -rf ${build_dir} ${ffmpeg32} ${root_dir:?}/ffmpeg32 ${root_dir:?}/ffmpeg64
}

if [ $1 ]; then
    $1
else
    Build
    Clean
fi

trap Clean EXIT