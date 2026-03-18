#!/bin/bash
set -e
lib_path="./lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

game_name="freesynd"
root_dir=$(pwd)
source_dir="${root_dir}/${game_name}-src"
build_dir="${root_dir}/${game_name}-build"
bin_dir="${root_dir}/${game_name}"
arch=$(uname -m)
version="0.7.1"
publish_dir="/build/artifacts/"

sdl12compat_dir="${root_dir}/sdl12-compat"
sdl12compat_build="${root_dir}/sdl12-compat-build"
sdl12compat_prefix="${root_dir}/sdl12-compat-install"

BuildSDL12Compat() {
    clone https://github.com/libsdl-org/sdl12-compat.git ${sdl12compat_dir}
    mkdir -p ${sdl12compat_build}
    cd ${sdl12compat_build}
    cmake -DCMAKE_INSTALL_PREFIX=${sdl12compat_prefix} \
          -DSDL12TESTS=OFF \
          ${sdl12compat_dir}
    make -j$(nproc)
    make install
}

GetSources() {
    if [[ -d $source_dir ]]; then
        rm -rf $source_dir
    fi
    svn co svn://svn.code.sf.net/p/freesynd/code/freesynd/tags/release-${version} ${source_dir}

    # Patch: resolve data path relative to the executable via /proc/self/exe
    # instead of the hardcoded PREFIX path
    sed -i '/ourDataDir = PREFIX"\/share\/freesynd\/data";/c\
            {\
                char buf[1024];\
                ssize_t len = readlink("/proc/self/exe", buf, sizeof(buf) - 1);\
                if (len > 0) {\
                    buf[len] = '"'"'\\0'"'"';\
                    string tmp(buf);\
                    size_t pos = tmp.find_last_of('"'"'/'"'"');\
                    if (pos != string::npos) tmp.erase(pos + 1);\
                    ourDataDir = tmp + "data";\
                } else {\
                    ourDataDir = PREFIX"/share/freesynd/data";\
                }\
            }' ${source_dir}/src/app.cpp
}

BuildProject() {
    mkdir -p ${build_dir}
    cd ${build_dir}
    cmake -DCMAKE_PREFIX_PATH=${sdl12compat_prefix} \
          -DSDL_INCLUDE_DIR=${sdl12compat_prefix}/include/SDL \
          -DSDL_LIBRARY=${sdl12compat_prefix}/lib/libSDL-1.2.so.0 \
          ${source_dir}
    make -j$(nproc)
}

PackageProject() {
    rm -rf ${bin_dir}
    mkdir -p ${bin_dir}

    cp ${build_dir}/src/freesynd ${bin_dir}/freesynd.bin

    mkdir -p ${bin_dir}/data
    cp -r ${source_dir}/data/* ${bin_dir}/data/

    cat << 'README' > ${bin_dir}/README
FreeSynd requires the original Syndicate (1993) game data files to play.
Files from Syndicate Plus or Syndicate Wars will NOT work.

Place the contents of the original game's DATA directory into one of:

  1. The "data" folder next to this executable, OR
  2. A directory of your choice, then set "data_dir" in the config file

The config file is located at: ~/.freesynd/freesynd.ini
It will be created automatically on first run. Set the data_dir option
to point to your original Syndicate DATA directory, for example:

  data_dir = /path/to/Syndicate/DATA

You can also pass the data path at launch with the -p flag:

  ./freesynd -p /path/to/Syndicate/DATA
README

    mkdir -p ${bin_dir}/lib
    # Bundle all shared library dependencies except glibc core libs
    ldd ${bin_dir}/freesynd.bin | grep "=> /" | awk '{print $3}' | while read lib; do
        case "$(basename $lib)" in
            libc.so*|libm.so*|libdl.so*|librt.so*|libpthread.so*|libresolv.so*|ld-linux*)
                ;; # skip glibc core
            *)
                cp -L "$lib" ${bin_dir}/lib/
                ;;
        esac
    done
    # Also grab the pulseaudio private lib
    cp -L /usr/lib/${arch}-linux-gnu/pulseaudio/libpulsecommon-*.so ${bin_dir}/lib/ 2>/dev/null || true

    strip --strip-unneeded ${bin_dir}/freesynd.bin
    strip --strip-unneeded ${bin_dir}/lib/*.so* 2>/dev/null || true

    cat << "WRAPPER" > ${bin_dir}/freesynd
#!/bin/bash
set -e
script_path="$(readlink -f $0)"
bin_dir="$(dirname $script_path)"
export LD_LIBRARY_PATH="$bin_dir/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
$bin_dir/freesynd.bin "$@"
WRAPPER
    chmod +x ${bin_dir}/freesynd

    cd ${root_dir}
    dest_file="${game_name}-${version}-${arch}.tar.xz"
    tar cJf ${dest_file} ${game_name}
    mkdir -p $publish_dir
    cp $dest_file $publish_dir
}

Clean() {
    rm -rf $build_dir $source_dir $sdl12compat_dir $sdl12compat_build $sdl12compat_prefix
}

if [ $1 ]; then
    $1
else
    BuildSDL12Compat
    GetSources
    BuildProject
    PackageProject
    Clean
fi
