#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=1.41
package_name='rtcw-sp'
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src
bin_dir=${root_dir}/${package_name}

clone https://github.com/hexameron/RTCW-SP-linux.git ${source_dir}

cd ${source_dir}
cd src/unix
./cons -- sdl2

cp -a sdl2-x86_64-Linux/out ${bin_dir}
cd ${root_dir}
tar czf ${package_name}-${version}-${arch}.tar.gz ${package_name}
rm -rf ${source_dir} ${bin_dir}
