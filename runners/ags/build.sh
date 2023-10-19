#!/bin/bash

set -e

lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
arch=$(uname -m)
root_dir=$(pwd)
publish_dir="/builds/runners/${runner_name}"
mkdir -p $publish_dir
deps="cmake debhelper build-essential pkg-config libsdl2-dev libogg-dev libtheora-dev libvorbis-dev"
install_deps $deps

rm -f *tar.gz

wget https://github.com/icculus/SDL_sound/archive/495e948b455af48eb45f75cccc060498f1e0e8a2.tar.gz
tar xvzf "495e948b455af48eb45f75cccc060498f1e0e8a2.tar.gz"
cd SDL_sound-495e948b455af48eb45f75cccc060498f1e0e8a2
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
make
sudo make install

cd $root_dir
clone https://github.com/adventuregamestudio/ags ags-src
cd ags-src
mkdir build-release
cd build-release
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .
mkdir ags.dir
mv ags ags.dir
mv ags.dir ags

arch=$(uname -m)
if [ "$arch" = "i686" ]; then
    BIT=32
    TRIPLET=i386-linux-gnu
elif [ "$arch" = "x86_64" ]; then
    BIT=64
    TRIPLET=x86_64-linux-gnu
else
    echo "Unsupported architecture $arch"
    exit 2
fi

mkdir -p ags/data/licenses
mkdir ags/data/lib$BIT

for library in \
    liballeg.so.4.4 \
    libaldmb.so.1 \
    libdumb.so.1 \
    libfreetype.so.6 \
    libSDL2_sound.so.2 \
    libogg.so.0 \
    libtheora.so.0 \
    libvorbis.so.0 \
    libvorbisfile.so.3 \
    allegro/4.4.3/alleg-alsadigi.so \
    allegro/4.4.3/alleg-alsamidi.so \
    allegro/4.4.3/modules.lst; do
        cp -L /usr/lib/$TRIPLET/$library ags/data/lib$BIT
done


(
cat << 'EOF'
#!/bin/bash
SCRIPTPATH="$(dirname "$(readlink -f $0)")"
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    lib_dir=$SCRIPTPATH/data/lib64
else
    lib_dir=$SCRIPTPATH/data/lib32
fi

export LD_LIBRARY_PATH="$lib_dir:$LD_LIBRARY_PATH"
ALLEGRO_MODULES="$lib_dir" "$SCRIPTPATH/ags" "$@"
EOF
) > ags/ags.sh
chmod +x ags/ags.sh
strip ags/ags
version=$(ags/ags.sh 2>/dev/null | grep version | head -n 1 | cut -d' ' -f 3 | tr -d ',')
ags_archive=ags-${version}-${arch}.tar.gz
tar czf $ags_archive ags
mv $ags_archive $root_dir
cd $root_dir
cp $ags_archive $publish_dir
echo $publish_dir/$ags_archive
