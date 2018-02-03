#!/bin/bash

set -e

source ../../lib/util.sh

# Run the built program with:
# mono osu\!.exe

version="git"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="osu"
source_dir="${root_dir}/osu-base"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    clone https://github.com/ppy/osu.git osu-base
    clone https://github.com/ppy/osu-framework osu-framework
    clone https://github.com/ppy/osu-resources osu-resources
    cd "${source_dir}"
    git submodule init
    git config submodule.osu-framework.url "${root_dir}/osu-framework"
    git config submodule.osu-resources.url "${root_dir}/osu-resources"
    git submodule update --recursive
    nuget restore
}

InstallBuildDependencies() {
    echo "TODO: Figure out how to install nuget4 in this section."
}

BuildProject() {
    cd "${source_dir}"
    # Setup environment for xbuild
    mkdir -p "osu.Game/bin/Release"
    ln -s "/lib/mono/4.5/Facades/netstandard.dll" "osu.Game/bin/Release"
    export MONO_IOMAP="case"

    # Build
    xbuild /property:Configuration=Release

    # Cleanup
    rm "osu.Game/bin/Release/netstandard.dll"
    rm "osu.Desktop/bin/Release/netstandard.dll"

}

PackageProject() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp -r ${source_dir}/osu.Desktop/bin/Release/* ${bin_dir}
    tar caf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

CleanUp() {
    rm -rf "${source_dir}"
    rm -rf "${root_dir}/osu-framework"
    rm -rf "${root_dir}/osu-resources"
    rm -rf "${bin_dir}"
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
