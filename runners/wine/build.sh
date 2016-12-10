#!/bin/bash

set -e

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${root_dir}

lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

buildbot32host="buildbot32"
buildbot64host="buildbot64"
runner_name=$(get_runner)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="1.8"
configure_opts=""

params=$(getopt -n $0 -o v:snd6k --long version:,staging,noupload,dependencies,64bit,keep -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -v|--version) version=$2; shift 2 ;;
        -s|--staging) STAGING=1; shift ;;
        -n|--noupload) NOUPLOAD=1; shift ;;
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        -6|--64bit) WOW64=1; shift ;;
        -k|--keep) KEEP=1; shift ;;
        *) shift; break ;;
    esac
done

InstallDependencies() {
    install_deps flex bison libfreetype6-dev libpulse-dev libattr1-dev  \
                libva-dev libva-drm1 autoconf autotools-dev debhelper desktop-file-utils \
                docbook-to-man docbook-utils docbook-xsl fontforge gettext libasound2-dev \
                libcapi20-dev libdbus-1-dev libfontconfig1-dev \
                libfreetype6-dev libgif-dev libgl1-mesa-dev libglu1-mesa-dev \
                libgphoto2-dev libgsm1-dev libgstreamer-plugins-base0.10-dev \
                libgstreamer0.10-dev libjpeg-dev liblcms2-dev libldap2-dev libmpg123-dev \
                libncurses5-dev libopenal-dev libosmesa6-dev libpcap0.8-dev libpng12-dev \
                libpulse-dev libsane-dev libtiff5-dev libv4l-dev libx11-dev \
                libxcomposite-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev \
                libxml2-dev libxrandr-dev libxrender-dev libxslt1-dev libxt-dev \
                libxxf86vm-dev ocl-icd-opencl-dev oss4-dev prelink \
                valgrind unixodbc-dev x11proto-xinerama-dev libgstreamer1.0-dev \
                libgstreamer-plugins-base1.0-dev gawk comerr-dev cpp-4.7 \
                dconf-gsettings-backend dconf-service esound-common gcc-4.7 gcc-4.7-base \
                gir1.2-atk-1.0 gir1.2-gdkpixbuf-2.0 gir1.2-gtk-3.0 gir1.2-pango-1.0 \
                krb5-multidev libacl1-dev libatk-bridge2.0-0 libatk-bridge2.0-dev \
                libatk1.0-dev libatspi2.0-0 libaudiofile-dev libaudiofile1 \
                libcairo-gobject2 libcairo-script-interpreter2 libcairo2-dev \
                libcloog-ppl1 libcolord1 libcups2-dev libdconf1 libesd0 libesd0-dev \
                libgcc-4.7-dev libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common \
                libgdk-pixbuf2.0-dev libgnutls-dev libgssrpc4 libgtk-3-0 \
                libgtk-3-common libgtk-3-dev libharfbuzz-dev libharfbuzz-gobject0 \
                libharfbuzz-icu0 libjasper1 libkadm5clnt-mit9 libkadm5srv-mit9 \
                libkrb5-dev liblzo2-2 libpango1.0-dev libpcap-dev \
                libpixman-1-dev libppl-c4 libssl-dev libudev-dev \
                libwayland-dev libxcb-shm0-dev libxft-dev libxkbcommon-dev sharutils

    release=$(lsb_release -rs)
    if [ "$release" = "16.04" ]; then
        install_deps libtxc-dxtn-s2tc-dev linux-libc-dev libkdb5-8 libppl13v5
    else
        install_deps libtxc-dxtn-dev linux-kernel-headers libkdb5-7 libppl13
    fi
}

DownloadWine() {
    wine_archive="wine-${version}.tar.bz2"
    mkdir -p .cache
    if [ ! -f ".cache/$wine_archive" ]; then
        echo "Downloading Wine ${version}"
        wget http://dl.winehq.org/wine/source/${version:0:3}/${wine_archive} -O .cache/${wine_archive}
    else
        echo "Wine ${version} already cached"
    fi
    tar xjf .cache/wine-${version}.tar.bz2
    if [ -d ${source_dir} ]; then
        rm -rf ${source_dir}
    fi
    mv wine-${version} ${source_dir}
}

DownloadWineStaging() {
    if [ $STAGING ]; then
        echo "Adding Wine Staging patches"
        cd ${source_dir}
        wget https://github.com/wine-compholio/wine-staging/archive/v${version}.tar.gz
        tar xvzf v${version}.tar.gz --strip-components 1
        ./patches/patchinstall.sh DESTDIR="$(pwd)" --all
        configure_opts="$configure_opts --with-xattr"
    fi
}

BuildWine() {
    prefix=${root_dir}/${bin_dir}
    mkdir -p $build_dir
    cd $build_dir

    # Do not use $arch here since it migth have been changed for the WOW64
    # build on the 32bit container
    if [ "$(uname -m)" = "x86_64" ]; then
        configure_opts="$configure_opts --enable-win64"
    fi

    # Third step to stitch together Wine64 and Wine32 build for the WOW64 build
    if [ "$1" = "combo" ]; then
        configure_opts="$configure_opts --with-wine64=../wine64 --with-wine-tools=../wine32"
    fi

    $source_dir/configure ${configure_opts} --prefix=$prefix
    make -j$(getconf _NPROCESSORS_ONLN)
}

# Build Wine, for the WOW64 version, this will be the regular build of 32bit wine
if [ "$WOW64" ]; then
    # Change arch name, this is used in the final file name and we want the
    # x86_64 part even on the 32bit container for WOW64.
    arch="x86_64"
fi

if [ "$STAGING" ]; then
    filename_opts="staging-"
fi

bin_dir="${filename_opts}${version}-${arch}"
wine32_archive="${bin_dir}-32bit.tar.gz"

cd ${root_dir}
if [ -f ${wine32_archive} ]; then
    # Extract the wine build received from the 32bit container
    tar xzf $wine32_archive
    cd $build_dir
else
    if [ "$INSTALL_DEPS" = "1" ]; then
        InstallDependencies
    fi
    DownloadWine
    DownloadWineStaging
    BuildWine

    if [ "$(uname -m)" = "x86_64" ]; then
        # Build the 64bit version of wine, send it to the 32bit container then exit
        cd ${root_dir}
        dest_file="${bin_dir}-build.tar.gz"
        mv wine wine64
        tar czf ${dest_file} wine64
        scp ${dest_file} ${buildbot32host}:${root_dir}
        mv wine64 wine
        rm ${dest_file}
        echo "Building 32bit wine"
        opts=""
        if [ $STAGING ]; then
            opts="--staging"
        fi
        if [ $KEEP ]; then
            opts="${opts} --keep"
        fi
        if [ $NOUPLOAD ]; then
            opts="${opts} --noupload"
        fi
        ssh -t ${buildbot32host} "${root_dir}/build.sh -v ${version} ${opts} --64bit"
        ./build.sh -v ${version} ${opts}
        exit
    fi

    if [ "$WOW64" ]; then
        cd ${root_dir}
        # Extract the 64bit build of Wine received from the buildbot64 container
        wine64build_archive="${filename_opts}${version}-x86_64-build.tar.gz"
        if [ ! -f $wine64build_archive ]; then
            echo "Missing wine64 build file $wine64build_archive"
            exit 2
        fi
        tar xzf $wine64build_archive

        # Rename the 32bit build of wine
        mv wine wine32

        # Build the combined Wine32 + Wine64
        BuildWine combo
        make install

        cd ${root_dir}
        # Package and send the build to the 64bit container
        tar czf ${wine32_archive} ${bin_dir}
        scp ${wine32_archive} ${buildbot64host}:${root_dir}
        if [ ! $KEEP ]; then
            rm -rf ${wine32_archive} ${wine64build_archive} wine32 wine64 ${bin_dir}
        fi
        exit
    fi
fi

make install

cd ${root_dir}
find ${bin_dir}/bin -type f -exec strip {} \;
find ${bin_dir}/lib -name "*.so" -exec strip {} \;
if [ -d ${bin_dir}/lib64 ]; then
    find ${bin_dir}/lib64 -name "*.so" -exec strip {} \;
fi
rm -rf ${bin_dir}/include

dest_file="wine-${filename_opts}${version}-${arch}.tar.gz"
tar czf ${dest_file} ${bin_dir}

if [ ! $NOUPLOAD ]; then
    runner_upload ${runner_name} ${filename_opts}${version} ${arch} ${dest_file}
fi

if [ ! $KEEP ]; then
    rm -rf ${build_dir} ${source_dir} ${bin_dir} ${dest_file}
fi
