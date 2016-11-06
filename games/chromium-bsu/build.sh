#!/bin/bash

set -e

source ../../lib/util.sh

version="0.9.16.1"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="chromium-bsu"
source_dir="${root_dir}/${pkg_name}-${version}"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"


InstallBuildDependencies() {
    install_deps libalut-dev libglc-dev libglu1-mesa-dev libopenal-dev \
        libsdl2-image-dev libsdl2-dev
}

GetSources() {
    cd $root_dir
    archive_name="chromium-bsu-$version.tar.gz"
    wget http://heanet.dl.sourceforge.net/project/chromium-bsu/Chromium%20B.S.U.%20source%20code/$archive_name
    tar xzf $archive_name
    rm $archive_name
}

BuildProject() {
    cd $source_dir
    ./configure --prefix=$build_dir
    make
    make install
}

PackageProject() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    mv $build_dir/share/chromium-bsu $bin_dir/data
    mv $build_dir/share/doc $bin_dir/doc
    mv $build_dir/bin $bin_dir/bin

    cat <<'EOF' > $bin_dir/chromium-bsu.sh
#!/bin/bash

cd "$(dirname "$0")/bin"
./chromium-bsu $@
EOF
    chmod +x $bin_dir/chromium-bsu.sh
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

CleanUp() {
    cd $root_dir
    rm -rf $build_dir
    rm -rf $bin_dir
    rm -rf $source_dir
}

if [ $1 ]; then
    $1
else
    # InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
    CleanUp
fi
