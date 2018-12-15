#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="gamecontrollerdb"
version="master"
root_dir=$(pwd)
source_dir="${root_dir}/SDL_GameControllerDB"
bin_dir="${root_dir}/gamecontrollerdb"


GetSources() {
    clone https://github.com/gabomdq/SDL_GameControllerDB.git $source_dir
}

BuildProject() {
    mkdir -p "${bin_dir}"
    cp "${source_dir}/gamecontrollerdb.txt" "${bin_dir}"
}


PackageProject() {
    cd "$root_dir"
    tar czf "${pkg_name}-$(date "+%Y%m%d").tar.gz" "${pkg_name}"
}

Cleanup() {
    cd "$root_dir"
    rm -rf "$bin_dir"
    rm -rf "$source_dir"
}


if [ "$1" ]; then
    $1
else
    GetSources $version
    BuildProject
    PackageProject
    Cleanup
fi
