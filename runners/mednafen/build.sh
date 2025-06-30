#!/bin/bash

set -e
lib_path="./lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name="mednafen"
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
publish_dir="/build/artifacts/"
arch="$(uname -m)"
version="1.32.1"

src_archive="${runner_name}-${version}.tar.xz"
src_url="https://mednafen.github.io/releases/files/${src_archive}"

deps="libsndfile-dev"
install_deps $deps

wget "${src_url}"
tar xJf "${src_archive}"
rm "${src_archive}"

mv mednafen "${source_dir}"
cd "${source_dir}"

./configure --prefix="${build_dir}"
make -j$(nproc)
make install

cd "${build_dir}"
strip bin/mednafen
mv bin/mednafen bin/mednafen.bin
mkdir lib
cp /usr/lib/x86_64-linux-gnu/libFLAC.so* lib

cat << "EOF" > bin/mednafen
#!/bin/bash

set -e
script_path="$(readlink -f $0)"
bin_dir="$(dirname $script_path)"
base_dir="$(dirname $bin_dir)"
export LD_LIBRARY_PATH="$base_dir/lib"
$bin_dir/mednafen.bin "$@"

EOF


chmod +x bin/mednafen

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.xz"
tar cJf "${dest_file}" "${runner_name}"
mkdir -p $publish_dir
cp $dest_file $publish_dir
rm -rf "${build_dir}" "${source_dir}"
