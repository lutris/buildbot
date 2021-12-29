#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name="$(get_runner)"
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-src/build"
arch=$(uname -m)

params=$(getopt -n $0 -o gd --long armv7l --long i686 --long x86_64 -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        #-d|--dependencies) INSTALL_DEPS=1; shift ;;
        --armv7l) arch="armv7l"; shift ;;
        --i686) arch="i686"; shift ;;
        --x86_64) arch="x86_64"; shift ;;
        *) shift; break ;;
    esac
done

export N_PREFIX=$root_dir/n # $root_dir shouldn't be needed, but an absolute path seems to be required by n
export PATH=$PATH:$N_PREFIX/.repo/bin:$N_PREFIX/bin
export NPM_CONFIG_USERCONFIG=$root_dir/.npmrc

InstallDeps() {
    #deps=""
    #install_deps $deps

    # install nodejs & npm, stable version
    if [ ! -d "n/.repo" ]
    then
        git clone https://github.com/tj/n.git "n/.repo" || true
    fi
    cd n/.repo
    git pull
    cd "$root_dir"

    n stable
    node -v
    # set npm cache location
    npm config set cache "$root_dir/npm-cache"
    # disable progress bar (for quicker installs)
    npm set progress=false

    sudo apt install -y bsdiff
}

BuildWeb() {
    # fetch
    if [ ! -d "$source_dir" ]
    then
        git clone https://github.com/lutris/web-runner.git "$source_dir" || true
    fi
    cd "$source_dir"
    git pull

    echo "Installing node modules..."
    npm install --only=dev
    cd electron-launcher && npm install --only=production && cd ..

    # build
    make cleanbuild
    make ${arch}

    cd "$root_dir"
}

PackageWeb() {

    cd "$source_dir"

    version=$(node -p "require('./package.json').version")

    cd "$root_dir"

    dest_file="${runner_name}-${version}-${arch}.tar.xz"

    package_arch="$arch"

    if [ "$arch" == "i386" ] || [ "$arch" == "i686" ]
    then
        package_arch="x86_32"
    elif [ "$arch" == "armv7l" ]
    then
        package_arch="armv7"
    fi

    tar -cJf "$dest_file" -C "$build_dir/${runner_name}-${package_arch}" --transform "s,^./,./${runner_name}/," .

    runner_upload ${runner_name} ${version} ${arch} "$dest_file"
}


InstallDeps
BuildWeb
PackageWeb
