#!/bin/bash

set -e
lib_path="./lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name="dolphin"
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
repo_url="https://github.com/dolphin-emu/dolphin"
version="2512"
publish_dir="/build/artifacts/"

GetSources() {
    if [[ -d $source_dir ]]; then
        rm -rf $source_dir
    fi
    clone $repo_url $source_dir "" $version
    cd $source_dir
    git submodule update --init --recursive
    cd ..
}

BuildProject() {
    cd "${source_dir}"
    mkdir -p ${build_dir}
    cd ${build_dir}
    cmake -DLINUX_LOCAL_DEV=1 -DENABLE_LLVM=OFF -DENCODE_FRAMEDUMPS=OFF -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14 ${source_dir}
    make -j$(nproc)
    cp -r ${source_dir}/Data/Sys/ Binaries/
    touch Binaries/portable.txt
}

GetVersion() {
    cd ${build_dir}
    version=$(grep SCM_DESC_STR Source/Core/Common/scmrev.h | cut -f 3 -d " " | tr -d "\"")
    export version=${version%-dirty}
}

PackageProject() {
    cd ${build_dir}
    rm -rf ${bin_dir}
    mkdir -p ${bin_dir}
    mv Binaries/* ${bin_dir}
    mkdir -p ${bin_dir}/lib
    cp -L /lib/x86_64-linux-gnu/libbz2.so* ${bin_dir}/lib/ 2>/dev/null || true
    cp -L /usr/lib/x86_64-linux-gnu/libQt6Core.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6Gui.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6Widgets.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6OpenGL.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6OpenGLWidgets.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6Svg.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6SvgWidgets.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6DBus.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6Network.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libQt6XcbQpa.so.6 ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libpcre2-16.so* ${bin_dir}/lib/ 2>/dev/null || true
    cp -L /usr/lib/x86_64-linux-gnu/libmd4c.so* ${bin_dir}/lib/ 2>/dev/null || true
    cp -L /usr/lib/x86_64-linux-gnu/libicui18n.so.67* ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libicuuc.so.67* ${bin_dir}/lib/
    cp -L /usr/lib/x86_64-linux-gnu/libicudata.so.67* ${bin_dir}/lib/
    mkdir -p ${bin_dir}/plugins/platforms
    cp -L /usr/lib/x86_64-linux-gnu/qt6/plugins/platforms/libqxcb.so ${bin_dir}/plugins/platforms/
    cp -L /usr/lib/x86_64-linux-gnu/qt6/plugins/platforms/libqwayland*.so ${bin_dir}/plugins/platforms/ 2>/dev/null || true
    mv ${bin_dir}/dolphin-emu ${bin_dir}/dolphin-emu.bin
    cat << "WRAPPER" > ${bin_dir}/dolphin-emu
#!/bin/bash
set -e
script_path="$(readlink -f $0)"
bin_dir="$(dirname $script_path)"
export LD_LIBRARY_PATH="$bin_dir/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="$bin_dir/plugins"
$bin_dir/dolphin-emu.bin "$@"
WRAPPER
    chmod +x ${bin_dir}/dolphin-emu
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.xz"
    tar cJf ${dest_file} ${runner_name}
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
    GetVersion
    PackageProject
fi
