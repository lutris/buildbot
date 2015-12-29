#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name=uhexen2
version=1.5.6
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src

svn checkout svn://svn.code.sf.net/p/uhexen2/code/trunk $source_dir
cd $source_dir
