#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)

deps="subversion"

install_deps $deps
svn checkout svn://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk ${source_dir}

mkdir -p ${build_dir}

cd $source_dir
./autogen.sh
./configure --prefix=${build_dir}
make
make install

revision=$(svn info | grep "^Revision" | cut -d" " -f 2)
version="svn${revision}"

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
