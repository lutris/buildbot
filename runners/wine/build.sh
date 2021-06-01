#!/bin/bash

set -e
set -x

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${root_dir}

lib_path="../../lib/"
runtime_path=$(readlink -f "../../runtime/extra/")
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

buildbot32host="buildbot32"
buildbot64host="buildbot64"
runner_name=$(get_runner)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="5.0"
configure_opts="--disable-tests --with-x --with-gstreamer"

params=$(getopt -n $0 -o a:b:w:v:p:snd6kfcm --long as:,branch:,with:,version:,patch:,staging,noupload,dependencies,64bit,keep,keep-upload-file,useccache,usemingw -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -a|--as) build_name=$2; shift 2 ;;
        -b|--branch) branch_name=$2; shift 2 ;;
        -w|--with) repo_url=$2; shift 2 ;;
        -v|--version) version=$2; shift 2 ;;
        -p|--patch) patch=$2; shift 2 ;;
        -s|--staging) STAGING=1; shift ;;
        -n|--noupload) NOUPLOAD=1; shift ;;
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        -6|--64bit) WOW64=1; shift ;;
        -k|--keep) KEEP=1; shift ;;
        -f|--keep-upload-file) KEEP_UPLOAD_FILE=1; shift ;;
        -c|--useccache) CCACHE=1; shift ;;
        -m|--usemingw) MINGW=1; shift ;;
        *) shift; break ;;
    esac
done

if [ "$build_name" ]; then
    filename_opts="${build_name}-"
elif [ "$STAGING" ]; then
    filename_opts="staging-"
fi

if [ "$WOW64" ]; then
    # Change arch name, this is used in the final file name and we want the
    # x86_64 part even on the 32bit container for WOW64.
    arch="x86_64"
fi

bin_dir="${filename_opts}${version}-${arch}"
wine32_archive="${bin_dir}-32bit.tar.gz"
dest_file="${bin_dir}-build.tar.gz"
upload_file="wine-${filename_opts}${version}-${arch}.tar.xz"

InstallDependencies() {
    sudo apt install -y autoconf bison ccache debhelper desktop-file-utils docbook-to-man \
        docbook-utils docbook-xsl flex fontforge gawk gettext libacl1-dev \
        libasound2-dev libcloog-ppl1 libcups2-dev libdbus-1-dev \
        libgcrypt-dev libgif-dev libglu1-mesa-dev libgsm1-dev libgtk-3-dev \
        liblcms2-dev libldap2-dev libmpg123-dev libncurses5-dev \
        libopenal-dev libosmesa6-dev libpcap-dev libpulse-dev \
        libssl-dev libtiff5-dev libudev-dev libv4l-dev libva-dev libxslt1-dev libxt-dev \
        ocl-icd-opencl-dev prelink valgrind linux-libc-dev libppl14 libcolord2 libvulkan-dev \
        libgnutls28-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
        libpng-dev libsdl2-dev libavcodec-dev \
	    libavutil-dev libswresample-dev libavcodec58 libswresample3 libavutil56 libfaudio0 libfaudio-dev \
        libvkd3d1 libvkd3d-dev libvkd3d-utils1 libvkd3d-shader1 vkd3d-demos libvulkan1 \
        libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x \
        gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio
}

DownloadWine() {
    # If a git repo as been specified use this instead and return
    if [[ $repo_url ]]; then
        # The branch name defaults to the build name
        branch_name=${branch_name:-$build_name}
        if [ -d "$source_dir" ]; then
          git -C "$source_dir" clean -dfx
          if [ $(git -C "$source_dir" branch -v | grep -o -E "$branch_name\s+") ]; then
                git -C "$source_dir" branch -m "$branch_name" "$branch_name"-old
          fi
	  git -C "$source_dir" fetch "$repo_url" "$branch_name":"$branch_name"
	  git -C "$source_dir" checkout "$branch_name"
          if [ $(git -C "$source_dir" branch -v | grep -o -E "$branch_name-old\s+") ]; then
                git -C "$source_dir" branch -D "$branch_name"-old
          fi
	else
            git clone -b "$branch_name" "$repo_url" "$source_dir"
	fi
        return
    fi

    IFS="." read major minor patch_num <<< "$version"
    if [[ $major -gt 1 && $minor -gt 0 ]]; then
        version_base="$major.x"
        wine_archive="wine-${version}.tar.xz"
    elif [[ $major -gt 1 && $minor -eq 0 ]]; then
        version_base=${version:0:3}
        wine_archive="wine-${version}.tar.xz"
    else
        version_base=${version:0:3}
        wine_archive="wine-${version}.tar.bz2"
    fi

    mkdir -p .cache
    if [ ! -f ".cache/$wine_archive" ]; then
        echo "Downloading Wine ${version}"
        wget http://dl.winehq.org/wine/source/$version_base/${wine_archive} -O .cache/${wine_archive}
    else
        echo "Wine ${version} already cached"
    fi
    tar xf .cache/$wine_archive
    if [ -d ${source_dir} ]; then
        rm -rf ${source_dir}
    fi
    mv wine-${version} ${source_dir}
}

DownloadWineStaging() {
    local ignore_errors
    if [ $STAGING ]; then
        echo "Adding Wine Staging patches"
        cd ${source_dir}
        staging_archive="v${version}.tar.gz"
        wget https://github.com/wine-staging/wine-staging/archive/${staging_archive} || true
        if [ -f $staging_archive ]; then
            tar xvzf ${staging_archive} --strip-components 1
            rm ${staging_archive}
            ignore_errors=false
        else
            echo "Wine staging v$version not found, reverting to current git master, safety not guaranteed."
            clone https://github.com/wine-staging/wine-staging.git ${source_dir}/wine-staging-git
            cd ${source_dir}
            mv ${source_dir}/wine-staging-git/* ${source_dir}
            rm -rf ${source_dir}/wine-staging-git
            ignore_errors=true
        fi
        ${source_dir}/patches/patchinstall.sh DESTDIR="$(pwd)" --all || $ignore_errors
        configure_opts="$configure_opts --with-xattr"
    fi
}

ApplyPatch() {
    cd ${root_dir}
    patch_path=$(realpath $patch)
    if [ ! -f $patch_path ]; then
        echo "Couldn't find patch $patch_path"
        exit 2
    fi
    echo "Applying patch $patch_path"
    cd $source_dir
    patch -p1 < $patch_path
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

    if [ "$(uname -m)" = "x86_64" ]; then
        export LD_LIBRARY_PATH=${runtime_path}/lib64
        custom_ld_flags="-L${runtime_path}/lib64 -Wl,-rpath-link,${runtime_path}/lib64"
    else
        export LD_LIBRARY_PATH=${runtime_path}/lib32
        custom_ld_flags="-L${runtime_path}/lib32 -Wl,-rpath-link,$runtime_path/lib32"
    fi

    if [ $CCACHE ]; then
        export CC="ccache gcc"
            if [ "$(uname -m)" = "x86_64" ]; then
                export CROSSCC="ccache x86_64-w64-mingw32-gcc"
            else
                export CROSSCC="ccache i686-w64-mingw32-gcc"
            fi
        else
        export CC="gcc"
            if [ "$(uname -m)" = "x86_64" ]; then
                export CROSSCC="x86_64-w64-mingw32-gcc"
            else
                export CROSSCC="i686-w64-mingw32-gcc"
            fi
    fi

    if [ $MINGW ]; then
        MINGW_STATE="--with-mingw"
        else
        MINGW_STATE="--without-mingw"
    fi

    LDFLAGS="$custom_ld_flags" $source_dir/configure ${configure_opts} --prefix=$prefix $MINGW_STATE
    make -j$(getconf _NPROCESSORS_ONLN)
}

BuildFinalWow64Build() {
    cd ${root_dir}
    # Extract the wine build received from the 32bit container
    tar xzf $wine32_archive
    cd $build_dir
    make install
}

Send64BitBuildAndBuild32bit() {
    # Build the 64bit version of wine, send it to the 32bit container then exit
    cd ${root_dir}

    # Package the 64bit build (in a wine64 folder)
    echo "Sending the 64bit build to the 32bit container"
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
    if [ $KEEP_UPLOAD_FILE ]; then
        opts="${opts} --keep-upload-file"
    fi
    if [ $NOUPLOAD ]; then
        opts="${opts} --noupload"
    fi
    if [ $INSTALL_DEPS ]; then
        opts="${opts} --dependencies"
    fi
    if [ $patch ]; then
        opts="${opts} --patch $patch"
    fi
    if [ $build_name ]; then
        opts="${opts} --as $build_name"
    fi
    if [ $repo_url ]; then
        opts="${opts} --with $repo_url"
    fi
    if [ "$branch_name" ]; then
        opts="${opts} --branch $branch_name"
    fi
    if [ "$CCACHE" ]; then
        opts="${opts} --useccache"
    fi
    if [ "$MINGW" ]; then
        opts="${opts} --usemingw"
    fi

    echo "Building 32bit wine on 32bit container"
    ssh -t ${buildbot32host} "${root_dir}/build.sh -v ${version} ${opts} --64bit"
    echo "Relaunch local build after the 32bit build finished"
    ./build.sh -v ${version} ${opts}
    echo "Build relaunched"
}

Combine64and32bitBuilds() {
    cd ${root_dir}
    # Extract the 64bit build of Wine received from the buildbot64 container
    wine64build_archive="${filename_opts}${version}-x86_64-build.tar.gz"
    if [ ! -f $wine64build_archive ]; then
        echo "Missing wine64 build file $wine64build_archive"
        exit 2
    fi
    tar xzf "$wine64build_archive"

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
        rm -rf ${build_dir} ${wine32_archive} ${wine64build_archive} wine32 wine64 ${bin_dir}
    fi
}

Build() {
    if [ -f ${wine32_archive} ]; then
        # The 64bit container has received the 32bit build
        BuildFinalWow64Build
    else
        if [ "$INSTALL_DEPS" = "1" ]; then
            InstallDependencies
        fi
        DownloadWine
        DownloadWineStaging
        if [ "$patch" ]; then
            ApplyPatch
        fi
        BuildWine

        if [ "$(uname -m)" = "x86_64" ]; then
            # Send the build to the 32bit container
            Send64BitBuildAndBuild32bit
            exit
        fi

        if [ "$WOW64" ]; then
            # On a 32bit container, build wine then send it back to the 64bit
            # container
            Combine64and32bitBuilds
            exit
        fi

        echo "Running make install"
        make install
    fi
}

Package() {
    cd ${root_dir}

    # Clean up wine build
    find ${bin_dir}/bin -type f -exec strip {} \;
    for _f in "$bin_dir"/{bin,lib,lib64}/{wine/*,*}; do
        if [[ "$_f" = *.so ]] || [[ "$_f" = *.dll ]]; then
            strip --strip-unneeded "$_f"
        fi
    done
    #copy sdl2, faudio, vkd3d, and ffmpeg libraries
    cp -R $runtime_path/lib32/* ${bin_dir}/lib/

    if [ "$(uname -m)" = "x86_64" ]; then
        mkdir -p ${bin_dir}/lib64/
        cp -R $runtime_path/lib64/* ${bin_dir}/lib64/
    fi

    rm -rf ${bin_dir}/include

    if [ -f ${root_dir}/${upload_file} ]; then
        rm ${root_dir}/${upload_file}
    fi
    tar cJf ${upload_file} ${bin_dir}
}

UploadRunner() {
    if [ ! $NOUPLOAD ]; then
        cd ${root_dir}
        runner_upload ${runner_name} ${filename_opts}${version} ${arch} ${dest_file}
    fi
}

PostClean() {
    if [ ! $KEEP ]; then
        cd ${root_dir}
        rm -rf ${build_dir} ${bin_dir} ${wine32_archive} ${dest_file}
      if [ ! $KEEP_UPLOAD_FILE ]; then
        rm -rf ${upload_file}
      fi
    fi
    echo "Cleaned up."
}

trap TrapClean ERR INT

TrapClean() {
    if [ ! $KEEP ]; then
        cd ${root_dir}
        rm -rf ${build_dir} ${bin_dir} ${wine32_archive} ${dest_file} ${upload_file}
    fi
    echo "Build failed, cleaned up."
}

if [ $1 ]; then
    $1
else
    Build
    Package
    UploadRunner
    PostClean
fi
