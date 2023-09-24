#!/bin/bash

set +x

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${root_dir}

lib_path="../../lib/"
runtime_path=$(readlink -f "../../runtime/extra/")
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
publish_dir="/builds/runners/${runner_name}"
configure_opts="--disable-tests --with-x --with-mingw --with-gstreamer"
arch=$(uname -m)
version="8.0"

params=$(getopt -n $0 -o a:b:w:v:t --long as:,branch:,with:,version:,nostrip -- "$@")
eval set -- $params
while true; do
	case "$1" in
	-a | --as)
		build_name=$2
		shift 2
		;;
	-b | --branch)
		branch_name=$2
		shift 2
		;;
	-w | --with)
		repo_url=$2
		shift 2
		;;
	-v | --version)
		version=$2
		shift 2
		;;
	-t | --nostrip)
		NOSTRIP=1
		shift
		;;
	*)
		shift
		break
		;;
	esac
done

if [ "$build_name" ]; then
	filename_opts="${build_name}-"
fi

bin_dir="${filename_opts}${version}-${arch}"

archive_filename="wine-${filename_opts}${version}-${arch}.tar.xz"

if [[ ! $repo_url ]]; then
	echo "Please provide repo URL"
	exit 2
fi
# The branch name defaults to the build name
branch_name=${branch_name:-$build_name}
if [ -d "$source_dir" ]; then
	git -C "$source_dir" clean -dfx
	if [ $(git -C "$source_dir" branch -v | grep -o -E "$branch_name\s+") ]; then
		git -C "$source_dir" branch -m "$branch_name" "$branch_name"-old
	fi
	git -C "$source_dir" fetch "$repo_url" "$branch_name":"$branch_name"
	git -C "$source_dir" checkout "$branch_name"
	git -C "$source_dir" pull --tags origin "$branch_name"
	if [ $(git -C "$source_dir" branch -v | grep -o -E "$branch_name-old\s+") ]; then
		git -C "$source_dir" branch -D "$branch_name"-old
	fi
else
	git clone -b "$branch_name" "$repo_url" "$source_dir"
fi

export BASEDIR=/home/vagrant/runners/wine/$bin_dir
mkdir -p $BASEDIR

cd ${source_dir}
echo "Building $(git log -1)"
echo "---"

# The only error we should see after configure is for inotify:
# $ cd ~/buildbot/runners/wine/wine-src/build64 (or build32)
# $ cat config.log | grep -i "was not found"
# configure:15812: libinotify errors: Package libinotify was not found in the pkg-config search path.
# https://wiki.winehq.org/Building_Wine

# Library name 	Debian 	Fedora 	Arch 	Function 	                Notes
# libinotify 	N/A 	N/A 	N/A 	File change notification 	Only necessary for some platforms (Linux does not need this.)

echo "Configuring 64 bit build"
mkdir -p build64
cd build64
CUPS_CFLAGS="-I/usr/include" \
PKG_CONFIG_PATH=/usr/share/pkgconfig \
LDFLAGS="-L${runtime_path}/lib64 -Wl,-rpath-link,${runtime_path}/lib64" \
../configure -q -C \
--enable-win64 \
--libdir="$BASEDIR"/lib64 \
--bindir="$BASEDIR"/bin \
--datadir="$BASEDIR"/share \
--mandir="$BASEDIR"/share/man \
${configure_opts}
CC="ccache gcc" CROSSCC="ccache x86_64-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib64 make -s -j$(nproc)
cd ..

echo "Configuring 32 bit build"
mkdir -p build32
cd build32
GSTREAMER_CFLAGS="-I/usr/include/gstreamer-1.0 -I/usr/include/glib-2.0 -I/usr/lib/i386-linux-gnu/glib-2.0/include -I/usr/include/i386-linux-gnu -I/usr/lib/i386-linux-gnu/gstreamer-1.0/include -I/usr/include/orc-0.4 -I/usr/include/gudev-1.0 -I/usr/include/libdrm -pthread" \
GCRYPT_LIBS="-lgcrypt" GCRYPT_CFLAGS="-I/usr/include/gcrypt.h" \
CUPS_CFLAGS="-I/usr/include" \
PKG_CONFIG_PATH=/usr/share/pkgconfig \
LDFLAGS="-L${runtime_path}/lib32 -Wl,-rpath-link,$runtime_path/lib32" \
../configure -q -C \
--libdir="$BASEDIR"/lib \
--bindir="$BASEDIR"/bin \
--datadir="$BASEDIR"/share \
--mandir="$BASEDIR"/share/man \
${configure_opts}
CC="ccache gcc" CROSSCC="ccache i686-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib32 make -s -j$(nproc)
cd ..

if ! test -s .git/rebase-merge/git-rebase-todo; then
	echo "Creating build at $build_dir"
	CC="ccache gcc" CROSSCC="ccache i686-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib32 make -s -j$(nproc) -C build32 install-lib
	CC="ccache gcc" CROSSCC="ccache x86_64-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib64 make -s -j$(nproc) -C build64 install-lib
fi

if [ -z $NOSTRIP ]; then
	echo "stripping build"
	find "$BASEDIR"/bin -type f -exec strip {} \;
	for _f in "$BASEDIR"/{bin,lib,lib64}/{wine/*,*}; do
		if [[ "$_f" = *.so ]] || [[ "$_f" = *.dll ]]; then
			strip --strip-unneeded "$_f" || true
		fi
	done
	for _f in "$build_dir"/{bin,lib,lib64}/{wine/{x86_64-unix,x86_64-windows,i386-unix,i386-windows}/*,*}; do
		if [[ "$_f" = *.so ]] || [[ "$_f" = *.dll ]]; then
			strip --strip-unneeded "$_f" || true
		fi
	done
fi

echo "Copying 64 bit runtime libraries to build"
#copy sdl2, faudio, vkd3d, and ffmpeg libraries
cp -R "$runtime_path"/lib64/* "$BASEDIR"/lib64/
cp -R "$runtime_path"/steam-linux-runtime/lib64/* "$BASEDIR"/lib64/

echo "Copying 32 bit runtime libraries to build"
#copy sdl2, faudio, vkd3d, and ffmpeg libraries
cp -R "$runtime_path"/lib32/* "$BASEDIR"/lib/
cp -R "$runtime_path"/steam-linux-runtime/lib32/* "$BASEDIR"/lib/

echo "Cleaning include files from build"
rm -rf "$BASEDIR"/include

echo "Copying wine-mono and wine-gecko to build"
if [ -d "$source_dir/lutris-patches/" ]; then
	cp -R "$source_dir/lutris-patches/mono" "$BASEDIR"/
	cp -R "$source_dir/lutris-patches/gecko" "$BASEDIR"/
fi

echo "Creating tarball from build at $BASEDIR"
cd /home/vagrant/runners/wine/ && tar cvJf ${archive_filename} ${bin_dir}
mkdir -p $publish_dir
sudo mv ${archive_filename} $publish_dir

echo "Build complete!"
