#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

buildbot32host="buildbot32"
runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="1.8"
repo_url="git://source.winehq.org/git/wine.git"

params=$(getopt -n $0 -o v:sn6 --long version:,staging,noupload,64bit -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -v|--version) version=$2; shift 2 ;;
        -s|--staging) STAGING=1; shift ;;
        -n|--noupload) NOUPLOAD=1; shift ;;
        -6|--64bit) WOW64=1; shift;;
        *) shift; break ;;
    esac
done

sudo apt-get install -y flex bison libfreetype6-dev \
                        libpulse-dev libattr1-dev libtxc-dxtn-dev \
                        libva-dev libva-drm1 autoconf \
                        autotools-dev debhelper desktop-file-utils \
                        docbook-to-man docbook-utils docbook-xsl fontforge \
                        gettext libasound2-dev libcapi20-dev libcups2-dev \
                        libdbus-1-dev libfontconfig1-dev libfreetype6-dev \
                        libgif-dev libgl1-mesa-dev libglu1-mesa-dev \
                        libgnutls-dev libgphoto2-dev libgsm1-dev \
                        libgstreamer-plugins-base0.10-dev libgstreamer0.10-dev \
                        libjpeg-dev liblcms2-dev libldap2-dev libmpg123-dev \
                        libncurses5-dev libopenal-dev libosmesa6-dev \
                        libpcap0.8-dev libpng12-dev libpulse-dev libsane-dev \
                        libtiff5-dev libv4l-dev libx11-dev libxcomposite-dev \
                        libxcursor-dev libxext-dev libxi-dev libxinerama-dev \
                        libxml2-dev libxrandr-dev libxrender-dev libxslt1-dev \
                        libxt-dev libxxf86vm-dev linux-kernel-headers \
                        ocl-icd-opencl-dev oss4-dev prelink valgrind \
                        unixodbc-dev x11proto-xinerama-dev

clone ${repo_url} ${source_dir}

echo "Checking out wine ${version}"
git checkout wine-${version}

configure_opts=""

if [ $STAGING ]; then
    echo "Adding Wine Staging patches"
    wget https://github.com/wine-compholio/wine-staging/archive/v${version}.tar.gz
    tar xvzf v${version}.tar.gz --strip-components 1
    ./patches/patchinstall.sh DESTDIR="$(pwd)" --all
    configure_opts="$configure_opts --with-xattr"
    filename_opts="staging-"
fi

if [ "$arch" = "x86_64" ]; then
    configure_opts="$configure_opts --enable-win64"
fi

# Build Wine, for the WOW64 version, this will be the regular build of 32bit
# wine
dest_dir="${filename_opts}${version}-${arch}"
prefix=${root_dir}/${dest_dir}
mkdir -p $build_dir
cd $build_dir
$source_dir/configure ${configure_opts} --prefix=$prefix
make -j 8

if [ "$arch" = "x86_64" ]; then
    # Build the 64bit version of wine, send it to the 32bit container then exit
    cd ${root_dir}
    dest_file="${dest_dir}-build.tar.gz"
    mv wine wine64
    tar czf ${dest_file} wine64
    scp ${dest_file} ${buildbot32host}:${root_dir}
    exit
fi

if [ "$WOW64" ]; then
    cd ${root_dir}
    # Extract the 64bit build of Wine received from the buildbot64 container
    wine64build_archive="${filename_opts}${version}-x86_64.tar.gz"
    if [ ! -f $wine64build_archive ]; then
        echo "Missing wine64 build file $wine64build_archive"
        exit 2
    fi
    tar xzf $wine64build_archive

    # Rename the 32bit build of wine
    mv wine wine32

    # Build the combined Wine32 + Wine64
    mkdir -p $build_dir
    cd $build_dir
    ${source_dir}/configure \
        ${configure_opts} \
        --with-wine64=../wine64 \
        --with-wine-tools=../wine32 \
        --prefix=$prefix
    make -j 8

    # Change arch name
    arch="x86_64"
fi

make install

cd ${root_dir}
find ${dest_dir}/bin -type f -exec strip {} \;
find ${dest_dir}/lib -name "*.so" -exec strip {} \;
rm -rf ${dest_dir}/include

dest_file="wine-${filename_opts}${version}-${arch}.tar.gz"
tar czf ${dest_file} ${dest_dir}

if [ ! $NOUPLOAD ]; then
    runner_upload ${runner_name} ${filename_opts}${version} ${arch} ${dest_file}
fi

#rm -rf ${build_dir} ${source_dir}
