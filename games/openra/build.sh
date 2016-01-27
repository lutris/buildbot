#!/bin/bash

set -e

source ../../lib/util.sh

version="20151224"
root_dir=$(pwd)
source_dir="${root_dir}/openra-src"

clone https://github.com/OpenRA/OpenRA.git $source_dir
cd $source_dir
git checkout release-${version}

mozroots --import --sync
make dependencies
make all
# mono --debug OpenRA.Game.exe
