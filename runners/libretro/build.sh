#!/bin/bash

set -e
set -x
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
retroarch_version="1.8.5
root_dir="$(pwd)"
source_dir="${root_dir}/libretro-super"
bin_dir="${root_dir}/retroarch"
cores_dir="${root_dir}/cores"
cpus=$(getconf _NPROCESSORS_ONLN)
arch=$(uname -m)
buildbotarch="x86"
if [ "$arch" == "x86_64"]; then
    buildbotarch="x64"
fi

params=$(getopt -n $0 -o d --long dependencies -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        *) shift; break ;;
    esac
done

core="$1"

clone git://github.com/libretro/libretro-super.git $source_dir
cd "${source_dir}"

mkdir -p ${bin_dir}

InstallDeps() {
    deps="build-essential libxkbcommon-dev zlib1g-dev libfreetype6-dev \
        libegl1-mesa-dev libgbm-dev nvidia-cg-toolkit nvidia-cg-dev libavcodec-dev \
        libsdl2-dev libsdl-image1.2-dev libxml2-dev"
    install_deps $deps
}

BuildRetroarch() {
    cd ${source_dir}
    ./libretro-fetch.sh retroarch
    cd ${source_dir}/retroarch
    git checkout "v$retroarch_version"
    ./configure --disable-ffmpeg --disable-qt
    make -j$cpus
    strip retroarch
    cp retroarch $bin_dir
    cp tools/cg2glsl.py ${bin_dir}/retroarch-cg2glsl

    # Assets
    # TODO: Restore files that pushed the package size to be too big
    # - assets/wallpapers
    # - assets/xmb/retroactive
    cp -a media/assets ${bin_dir}
    rm -rf ${bin_dir}/assets/.git \
        ${bin_dir}/assets/src \
        ${bin_dir}/assets/switch \
        ${bin_dir}/assets/nxrgui \
        ${bin_dir}/assets/wallpapers \
        ${bin_dir}/assets/xmb/retroactive

    # autoconfig
    cp -a media/autoconfig ${bin_dir}

    # Info files
    cp -a ../dist/info ${bin_dir}

    # Database
    mkdir -p ${bin_dir}/database
    cp -a -t ${bin_dir}/database media/libretrodb/cht media/libretrodb/cursors media/libretrodb/rdb
}

BuildLibretroCore() {
    core="$1"
    is_hw=0
    cd ${source_dir}
    if [ "$core" = "mednafen_psx_hw" ]; then
        core="mednafen_psx"
        is_hw=1
        core_dir="libretro-$core"
        if [ ! -d "$core_dir" ]; then
            echo "You must first build mednafen_psx"
            exit 2
        fi
        cd $core_dir
        sed -ri "s/(HAVE_OPENGL ?= ?)0/\11/" Makefile
        make clean
        make
        cp mednafen_psx_hw_libretro.so ${cores_dir}
        git reset --hard
        cd ..
    else
        SINGLE_CORE=$core FORCE=YES NOCLEAN=1 SHALLOW_CLONE=1 EXIT_ON_ERROR=1 ./libretro-buildbot-recipe.sh recipes/linux/cores-linux-${buildbotarch}-generic
        ./libretro-install.sh ${cores_dir}
    fi
}

PackageRetroarch() {
    cd $root_dir
    archive="retroarch-${retroarch_version}-${arch}.tar.gz"
    tar czf $archive retroarch
    runner_upload ${runner_name} "retroarch-${retroarch_version}" ${arch} ${archive}
}

PackageCore() {
    core=$1
    cd ${cores_dir}
    archive="libretro-${core}-${arch}.tar.gz"
    core_file="${core}_libretro.so"
    tar czf ../${archive} ${core_file}
    rm $core_file
    cd $root_dir
    runner_upload ${runner_name} ${core} ${arch} $archive
}

if [ $INSTALL_DEPS ]; then
    InstallDeps
fi

if [ $1 ]; then
    if [[ $1 == 'all' ]]; then
        cd $root_dir
        for core in $(cat cores.list); do
            BuildLibretroCore $core
            PackageCore $core
        done
    else
        BuildLibretroCore $1
        PackageCore $1
    fi
else
    BuildRetroarch
    PackageRetroarch
fi
