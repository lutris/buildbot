#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name='serious-engine'
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src
bin_dir=${root_dir}/${package_name}

clone https://github.com/rcgordon/Serious-Engine.git $source_dir

cd $source_dir/Sources
./build-linux.sh

