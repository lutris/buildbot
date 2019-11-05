#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch="$(uname -m)"
version="1.21.3"

src_archive="${runner_name}-${version}.tar.xz"
src_url="https://mednafen.github.io/releases/files/${src_archive}"

deps="libsndfile-dev"
sudo apt install -y $deps

wget "${src_url}"
tar xJf "${src_archive}"
rm "${src_archive}"

mv mednafen "${source_dir}"
cd "${source_dir}"

./configure --prefix="${build_dir}"
make
make install

cd "${build_dir}"
strip bin/mednafen

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.xz"
tar cJf "${dest_file}" "${runner_name}"
runner_upload "${runner_name}" "${version}" "${arch}" "${dest_file}"
rm -rf "${build_dir}" "${source_dir}"
