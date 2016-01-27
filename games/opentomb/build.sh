#!/bin/bash

set -e

source ../../lib/util.sh

version="master"
root_dir=$(pwd)
source_dir="${root_dir}/opentomb-src"

clone https://github.com/opentomb/OpenTomb.git $source_dir

cd $source_dir


