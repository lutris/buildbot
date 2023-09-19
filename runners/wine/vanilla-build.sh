#!/bin/bash

set +x

trap TrapClean ERR INT

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${root_dir}

lib_path="../../lib/"
runtime_path=$(readlink -f "../../runtime/extra/")
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
configure_opts="--disable-tests --with-x"
arch=$(uname -m)
version="8.0"

params=$(getopt -n $0 -o a:b:w:v:p:snfcmt --long as:,branch:,with:,version:,patch:,staging,noupload,keep-upload-file,useccache,usemingw,nostrip -- "$@")
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
        -f|--keep-upload-file) KEEP_UPLOAD_FILE=1; shift ;;
        -c|--useccache) CCACHE=1; shift ;;
        -m|--usemingw) MINGW=1; shift ;;
        -t|--nostrip) NOSTRIP=1; shift ;;
        *) shift; break ;;
    esac
done

if [ "$build_name" ]; then
    filename_opts="${build_name}-"
elif [ ! -z "$STAGING" ]; then
    filename_opts="staging-"
fi


bin_dir="${filename_opts}${version}-${arch}"
prefix=${root_dir}/${bin_dir}
upload_file="wine-${filename_opts}${version}-${arch}.tar.xz"

    if [ ! -z $CCACHE ]; then
        ccache="ccache"
    fi

    if [ ! -z $MINGW ]; then
        MINGW_STATE="--with-mingw"
        else
        MINGW_STATE="--without-mingw"
    fi

TrapClean() {
    if [ ! $KEEP ]; then
        cd ${root_dir}
        rm -rf ${build_dir} ${bin_dir} ${upload_file}
    fi
    printf "Build failed, cleaned up.\n"
    exit
}

DownloadWine() {
    trap TrapClean ERR INT
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
      git -C "$source_dir" pull --tags origin "$branch_name"
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
    trap TrapClean ERR INT
    local ignore_errors
    if [  ! -z $STAGING ]; then
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
    trap TrapClean ERR INT
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

DownloadWine
DownloadWineStaging

if [ "$patch" ]; then
    ApplyPatch
fi


cd ${source_dir}
echo "Building $(git log -1)"
echo "---"


mkdir -p build64
cd build64
CC="$ccache gcc" CROSSCC="$ccache x86_64-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib64 LDFLAGS="-L${runtime_path}/lib64 -Wl,-rpath-link,${runtime_path}/lib64" ../configure -q -C --enable-win64 --libdir=$prefix/lib64 ${configure_opts} $MINGW_STATE
make -s -j$(nproc)
cd ..

mkdir -p build32
cd build32
CC="$ccache gcc" CROSSCC="$ccache i686-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib32 LDFLAGS="-L${runtime_path}/lib32 -Wl,-rpath-link,$runtime_path/lib32" ../configure -q -C --libdir=$prefix/lib ${configure_opts} $MINGW_STATE
make -s -j$(nproc)
cd ..

build_dir=/vagrant/$prefix
mkdir -p $build_dir

if ! test -s .git/rebase-merge/git-rebase-todo
then
    make -s -j$(nproc) -C build32 install-lib DESTDIR=$build_dir
    make -s -j$(nproc) -C build64 install-lib DESTDIR=$build_dir
fi

    # Clean up wine build
    if [ -z  $NOSTRIP ]; then
        find "$build_dir"/bin -type f -exec strip {} \;
        for _f in "$build_dir"/{bin,lib,lib64}/{wine/*,*}; do
            if [[ "$_f" = *.so ]] || [[ "$_f" = *.dll ]]; then
                strip --strip-unneeded "$_f" || true
            fi
        done
        for _f in "$build_dir"/{bin,lib,lib64}/{wine/{x86_64-unix,x86_64-windows,i386-unix,i386-windows}/*,*}; do
            if [[ "$_f" = *.so ]] || [[ "$_f" = *.dll ]]; then
                strip --strip-unneeded "$_f" || true
            fi
        done
    fi

    #copy sdl2, faudio, vkd3d, and ffmpeg libraries
    cp -R "$runtime_path"/lib32/* "$build_dir"/lib/

    #copy sdl2, faudio, vkd3d, and ffmpeg libraries
    cp -R "$runtime_path"/lib64/* "$build_dir"/lib64/

    rm -rf "$build_dir"/include

    if [ -d "$source_dir/lutris-patches/" ]; then
        cp -R "$source_dir/lutris-patches/mono" "$build_dir"/
        cp -R "$source_dir/lutris-patches/gecko" "$build_dir"/
    fi

    cd /vagrant/ && tar cJf ${upload_file} ${bin_dir}
# git reset --hard
