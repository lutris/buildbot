#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
arch="$(uname -m)"
version="2.9"

filename_ext="linux64-${version}"

dest_file=${runner_name}-${version}-${arch}.tar.gz
wget https://github.com/mupen64plus/mupen64plus-core/releases/download/${version}/mupen64plus-bundle-${filename_ext}.tar.gz -O $dest_file
mkdir -p $publish_dir
cp $dest_file $publish_dir
