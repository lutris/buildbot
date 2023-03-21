#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name='serious-sam'
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src
tfe_bin_dir=${root_dir}/${package_name}-tfe
tse_bin_dir=${root_dir}/${package_name}-tse

Fetch() {
    clone https://github.com/tx00100xt/SeriousSamClassic $source_dir
}

BuildTFE() {
    cd $source_dir/SamTFE/Sources
    ./build-linux64.sh -DTFE=TRUE
}

BuildTSE() {
    cd $source_dir/SamTSE/Sources
    ./build-linux64.sh
}

PackageTFE() {
    mkdir -p $tfe_bin_dir
    cd $source_dir/SamTFE/Bin
    cp * $tfe_bin_dir

    cd $tfe_bin_dir
    tar cfJ $root_dir/serious-sam-tfe-${arch}.tar.xz *
}


PackageTSE() {
    mkdir -p $tse_bin_dir
    cd $source_dir/SamTSE/Bin
    cp * $tse_bin_dir

    cd $tse_bin_dir
    tar cfJ $root_dir/serious-sam-tse-${arch}.tar.xz *
}

Clean() {
    rm -rf $source_dir
}


if [ $1 ]; then
    $1
else
    Fetch
    BuildTFE
    BuildTSE
    PackageTFE
    PackageTSE
fi
