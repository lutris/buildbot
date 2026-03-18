#!/bin/bash
set -e

lib_path="./lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

game_name="acgc-pc-port"
root_dir=$(pwd)
source_dir="${root_dir}/${game_name}-src"
build_dir="${root_dir}/${game_name}-build"
bin_dir="${root_dir}/${game_name}"
arch=$(uname -m)
version="0.8"
publish_dir="/build/artifacts/"

repo_url="https://github.com/strycore/ACGC-PC-Port.git"

GetSources() {
    if [[ -d $source_dir ]]; then
        rm -rf $source_dir
    fi
    clone $repo_url $source_dir --recursive linux
    cd $source_dir
    git submodule update --init --recursive
    cd ..
}

BuildProject() {
    mkdir -p ${build_dir}
    cd ${build_dir}
    cmake \
        -DCMAKE_C_COMPILER=i686-linux-gnu-gcc-10 \
        -DCMAKE_CXX_COMPILER=i686-linux-gnu-g++-10 \
        -DCMAKE_C_FLAGS="-m32 -D_GNU_SOURCE" \
        -DCMAKE_CXX_FLAGS="-m32 -D_GNU_SOURCE" \
        ${source_dir}/pc
    make -j$(nproc)
}

PackageProject() {
    rm -rf ${bin_dir}
    mkdir -p ${bin_dir}
    mkdir -p ${bin_dir}/rom
    mkdir -p ${bin_dir}/texture_pack
    mkdir -p ${bin_dir}/save

    cp ${build_dir}/bin/AnimalCrossing ${bin_dir}/AnimalCrossing.bin
    cp -r ${build_dir}/bin/shaders ${bin_dir}/

    mkdir -p ${bin_dir}/lib
    for lib in libSDL2 libsndio libasound libpulse libpulsecommon libpulse-simple \
               libwayland-client libwayland-cursor libwayland-egl libdbus-1 \
               libsystemd libgcrypt libgpg-error liblzma liblz4 libzstd libcap; do
        cp -L /usr/lib/i386-linux-gnu/${lib}.so* ${bin_dir}/lib/ 2>/dev/null || true
        cp -L /lib/i386-linux-gnu/${lib}.so* ${bin_dir}/lib/ 2>/dev/null || true
    done

    strip --strip-unneeded ${bin_dir}/AnimalCrossing.bin
    strip --strip-unneeded ${bin_dir}/lib/*.so* 2>/dev/null || true

    cat << "WRAPPER" > ${bin_dir}/AnimalCrossing
#!/bin/bash
set -e
script_path="$(readlink -f $0)"
bin_dir="$(dirname $script_path)"
export LD_LIBRARY_PATH="$bin_dir/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
$bin_dir/AnimalCrossing.bin "$@"
WRAPPER
    chmod +x ${bin_dir}/AnimalCrossing

    cd ${root_dir}
    dest_file="${game_name}-${version}-${arch}.tar.xz"
    tar cJf ${dest_file} ${game_name}
    mkdir -p $publish_dir
    cp $dest_file $publish_dir
}

Clean() {
    rm -rf $build_dir $source_dir
}

if [ $1 ]; then
    $1
else
    GetSources
    BuildProject
    PackageProject
fi
