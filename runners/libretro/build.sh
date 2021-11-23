#!/bin/bash

set -e
set -x
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir="$(pwd)"
source_dir="${root_dir}/libretro-super"
bin_dir="${root_dir}/retroarch"
cores_dir="${root_dir}/cores"
cpus=$(getconf _NPROCESSORS_ONLN)
arch=$(uname -m)
buildbotarch="x86"
if [ "$arch" == "x86_64" ]; then
    buildbotarch="x64"
fi

params=$(getopt -n $0 -o dn --long dependencies,noupload -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        -n|--noupload) NOUPLOAD=1; shift ;;
        *) shift; break ;;
    esac
done

core="$1"

clone https://github.com/libretro/libretro-super.git $source_dir
cd "${source_dir}"

mkdir -p ${bin_dir}

InstallDeps() {
    deps="build-essential cmake libxkbcommon-dev zlib1g-dev libfreetype6-dev \
        libegl1-mesa-dev libgbm-dev libavcodec-dev libsdl2-dev libpcap-dev \
        libxml2-dev unzip nasm"
    install_deps $deps
}

BuildRetroarch() {
    cd ${source_dir}
    ./libretro-fetch.sh retroarch
    cd ${source_dir}/retroarch
    retroarch_version=$(git describe --tags `git rev-list --tags --max-count=1`)
    git checkout $retroarch_version
    ./configure --disable-ffmpeg --disable-qt --disable-caca --disable-cg
    make -j$cpus
    strip retroarch
    cp retroarch $bin_dir

    # Assets
    # TODO: Restore files that pushed the package size to be too big
    # - assets/wallpapers
    # - assets/xmb/retroactive
    make -C media/assets install DESTDIR="${bin_dir}" INSTALLDIR=/assets
    rm -rf ${bin_dir}/assets/.git \
        ${bin_dir}/assets/src \
        ${bin_dir}/assets/switch \
        ${bin_dir}/assets/nxrgui \
        ${bin_dir}/assets/wallpapers \
        ${bin_dir}/assets/xmb/automatic \
        ${bin_dir}/assets/xmb/dot-art \
        ${bin_dir}/assets/xmb/neoactive \
        ${bin_dir}/assets/xmb/retrosystem \
        ${bin_dir}/assets/xmb/systematic

    # autoconfig
    make -C media/autoconfig install DESTDIR="${bin_dir}" INSTALLDIR=/autoconfig

    # Info files
    cp -a ../dist/info ${bin_dir}

    # Database
    make -C media/libretrodb install DESTDIR="${bin_dir}" INSTALLDIR=/database
}

BuildLibretroCore() {
    core="$1"
    cd ${source_dir}
    SINGLE_CORE=$core FORCE=YES NOCLEAN=1 SHALLOW_CLONE=1 EXIT_ON_ERROR=1 ./libretro-buildbot-recipe.sh recipes/linux/cores-linux-${buildbotarch}-generic
    ./libretro-install.sh ${cores_dir}
}

PackageRetroarch() {
    cd $root_dir
    archive="retroarch-${retroarch_version}-${arch}.tar.xz"
    tar cJf $archive retroarch
    if [ ! $NOUPLOAD ]; then
        runner_upload ${runner_name} "retroarch-${retroarch_version}" ${arch} ${archive}
    fi
    rm -rf retroarch
}

PackageCore() {
    core=$1
    cd ${cores_dir}
    archive="libretro-${core}-${arch}.tar.xz"
    core_file="${core}_libretro.so"
    tar cJf ../${archive} ${core_file}
    rm $core_file
    cd $root_dir
    if [ ! $NOUPLOAD ]; then
        runner_upload ${runner_name} ${core} ${arch} $archive
    fi
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
