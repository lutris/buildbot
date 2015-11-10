#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
arch="$(uname -m)"
version="2.5"

if [ "$arch" = "x86_64" ]; then
    filename_ext="linux64-${version}-ubuntu"
else
    filename_ext="linux32-${version}"
fi

dest_file=${runner_name}-${version}-${arch}.tar.gz
wget https://github.com/mupen64plus/mupen64plus-core/releases/download/${version}/mupen64plus-bundle-${filename_ext}.tar.gz -O $dest_file

runner_upload ${runner_name} ${version} ${arch} ${dest_file}
