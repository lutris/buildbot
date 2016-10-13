#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
arch=$(uname -m)
root_dir=$(pwd)

deps="debhelper build-essential pkg-config libaldmb1-dev libfreetype6-dev libtheora-dev libvorbis-dev libogg-dev"
install_deps $deps

git clone git://github.com/adventuregamestudio/ags.git ags-src
cd ags-src
make --directory=Engine
cd Engine
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
    libogg.so.0 \
    libtheora.so.0 \
    libvorbis.so.0 \
    libvorbisfile.so.3 \
    allegro/4.4.2/alleg-alsadigi.so \
    allegro/4.4.2/alleg-alsamidi.so \
    allegro/4.4.2/modules.lst; do
        cp -L /usr/lib/$TRIPLET/$library ags/data/lib$BIT
done

for package in \
    liballegro4.4 \
    libdumb1 \
    libfreetype6 \
    libogg0 \
    libtheora0 \
    libvorbis0a; do
        cp /usr/share/doc/$package/copyright ags/data/licenses/$package-copyright
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
version=$(ags/ags | grep version | head -n 1 | cut -d' ' -f 3)
ags_archive=ags-${version}-${arch}.tar.gz
tar czf $ags_archive ags
mv $ags_archive $root_dir
cd $root_dir
runner_upload ${runner_name} ${version} ${arch} ${ags_archive}
