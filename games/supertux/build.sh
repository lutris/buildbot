#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=0.4.0
arch=$(uname -m)
source_dir=${root_dir}/supertux-${version}
build_dir=${root_dir}/supertux-build
bin_dir=${root_dir}/supertux

deps="libphysfs-dev libcurl4-gnutls-dev libglew-dev libsdl2-image-dev"
install_deps $deps

clone https://github.com/SuperTux/supertux.git $source_dir
cd $source_dir
git submodule update --init --recursive

mkdir -p $build_dir
cd $build_dir

cmake ${source_dir}
make -j 8

mkdir -p ${bin_dir}
mkdir -p ${bin_dir}/lib
cp -a supertux2 ${bin_dir}
cp -a data ${bin_dir}
# cp -a external/squirrel/libsquirrel.so ${bin_dir}/lib
cp -a external/tinygettext/libtinygettext.so ${bin_dir}/lib

cd ${bin_dir}
cat <<'EOF' > supertux.sh
#!/bin/bash

cd "$(dirname "$0")"

export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
./supertux2 $@

EOF


chmod +x supertux.sh

cd ${root_dir}
tar czf supertux-${version}-${arch}.tar.gz supertux
