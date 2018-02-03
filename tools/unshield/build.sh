#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="unshield"
version="1.3"
arch=$(uname -m)
root_dir=$(pwd)
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"


GetSources() {
    clone https://github.com/twogood/unshield.git $source_dir
}

BuildProject() {
    cd "${source_dir}"
    mkdir -p $build_dir
    cd $build_dir
    cmake $source_dir
    make
}

PackageProject() {
    mkdir -p $bin_dir
    mv ${build_dir}/lib/libunshield* $bin_dir
    mv ${build_dir}/src/unshield* $bin_dir
    cd ${bin_dir}
    mv unshield unshield.bin
    cat << 'EOF' > unshield
#!/bin/bash
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LD_PRELOAD=$CWD/libunshield.so.1.3 $CWD/unshield.bin "$@"
EOF
    cd $root_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Cleanup() {
    cd $root_dir
    rm -rf $bin_dir
    rm -rf $build_dir
    rm -rf $source_dir
}


if [ $1 ]; then
    $1
else
    GetSources $version
    BuildProject
    PackageProject
    Cleanup
fi
