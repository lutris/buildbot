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
    sudo apt-get update
    sudo apt-get install dh-make bzr-builddeb mono-complete ffmpeg
    mkdir -p nuget_4.4.1-1/usr/bin
    cd "${root_dir}/nuget_4.4.1-1/usr/bin"
    wget https://dist.nuget.org/win-x86-commandline/v4.4.1/nuget.exe
    echo '#!/bin/sh
mono --runtime=v4.0 /usr/lib/nuget/nuget.exe $*' > nuget
    chmod a+x nuget
    mkdir -p ../../DEBIAN
    cd ../../DEBIAN
    echo 'Package: nuget4
Version: 4.4.1-1
Section: base
Priority: optional
Architecture: amd64
Depends: mono-complete (>= 5.0)
Maintainer: none
Description: Package manager for .NET.' > control
    cd ../..
    dpkg-deb --build nuget_4.4.1-1
    sudo dpkg -i nuget_4.4.1-1.deb
    rm -r nuget*
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
    InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
    CleanUp
fi
