#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

params=$(getopt -n $0 -o gd --long dependencies -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        *) shift; break ;;
    esac
done

runner_name="$(get_runner)"
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-src/build"
arch=$(uname -m)

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
}

BuildElectron() {
    # fetch
    if [ ! -d "$source_dir" ]
    then
        git clone https://github.com/daniel-j/lutris-electron-runner.git "$source_dir" || true
    fi
    cd "$source_dir"
    git pull

    npm install --only=dev

    # build
    make cleanbuild
    make ${arch}

    cd "$root_dir"
}

PackageElectron() {
    cd "$source_dir"

    version=$(node -p "require('./package.json').version")

    cd ${root_dir}

    dest_file="${runner_name}-${version}-${arch}.tar.gz"

    if [ "$arch" == "x86_64" ]
    then
        electron_arch="x64"
    else
        electron_arch="ia32"
    fi

    tar -zcf ${dest_file} -C "$build_dir/electron-runner-linux-${electron_arch}" .

    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
}

if [ $INSTALL_DEPS ]; then
    InstallDeps
fi

BuildElectron
PackageElectron
