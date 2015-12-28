#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
bin_dir="${root_dir}/${runner_name}"
arch="$(uname -m)"
version="v1.2.2"

repo_url="https://github.com/libretro/RetroArch"
rm -rf $source_dir
clone $repo_url $source_dir

deps="libglu1-mesa-dev freeglut3-dev mesa-common-dev libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev unzip"
install_deps $deps

cd $source_dir
git checkout ${version}
./configure
make

cd ..
rm -rf ${bin_dir}
mkdir -p ${bin_dir}
mv ${source_dir}/retroarch ${bin_dir}
cd ${bin_dir}

# Download the Asset Database
wget https://github.com/libretro/retroarch-assets/archive/master.zip
mv master.zip retroarch-assets.zip

# Download the database files
wget https://github.com/libretro/libretro-database/archive/master.zip
mv master.zip libretro-database.zip

# Download the Cores
cores=( 2048 bluemsx desmume dinothawr dosbox emux_gb emux_nes emux_sms fceumm fuse gambatte genesis_plus_gx gpsp gw handy mednafen_gba mednafen_lynx mednafen_snes mednafen_supergrafx mednafen_vb mednafen_wswan mgba mupen64plus nestopia nxengine pcsx_rearmed picodrive prboom quicknes snes9x_next stella vba_next vbam yabause )
for i in "${cores[@]}"
do
	wget http://buildbot.libretro.com/nightly/linux/${arch}/latest/${i}_libretro.so.zip
done

# Extract all the zip files.
unzip -o '*.zip'
rm *.zip

# Set up the resources and scripts
cp ${root_dir}/resources/* ${bin_dir}
chmod +x retroarch.sh
cd ${root_dir}

# Compress it all together
dest_file="${root_dir}/${runner_name}-${version}-${arch}.tar.gz"
tar -zcvf ${dest_file} ${bin_dir}

#runner_upload ${runner_name} ${version} ${arch} ${dest_file}
rm -rf ${source_dir} ${bin_dir}
