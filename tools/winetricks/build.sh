#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="winetricks"
arch=$(uname -m)
root_dir=$(pwd)
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"
date=$(date '+%Y%m%d')
dest_file="${pkg_name}-${date}-${arch}.tar.xz"


GetSources() {
    if [ -d "$source_dir" ]; then
      git -C "$source_dir" fetch
      git -C "$source_dir" reset --hard origin/master
    else
      git clone https://github.com/Winetricks/winetricks.git "$source_dir"
    fi
}

BuildProject() {
    cd "${source_dir}"

    # Apply all patches	
    for i in ../patches/*.patch; do patch -Np1 < $i; done
    mkdir -p "${bin_dir}"
    cp "${source_dir}/src/winetricks" "${bin_dir}"
}


PackageProject() {
    cd "$root_dir"
    tar cJf "${pkg_name}-${date}-${arch}.tar.xz" "${pkg_name}"
}

UploadRunner() {
    cd ${root_dir}
    aws s3 --endpoint-url=https://nyc3.digitaloceanspaces.com cp ${dest_file} s3://lutris/tools/winetricks/
    s3cmd setacl s3://lutris/tools/winetricks/${dest_file} --acl-public
    echo url="https://lutris.nyc3.cdn.digitaloceanspaces.com/tools/winetricks/${dest_file}"
}

Cleanup() {
    cd "$root_dir"
    rm -rf "$bin_dir"
}


if [ "$1" ]; then
    $1
else
    GetSources
    BuildProject
    PackageProject
    UploadRunner
    Cleanup
fi
