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
configure_opts="--disable-tests --with-x --with-mingw"
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




DownloadWine() {
	# If a git repo as been specified use this instead and return
	if [[ $repo_url ]]; then
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
		return
	fi

	IFS="." read major minor patch_num <<<"$version"
	if [[ $major -gt 1 && $minor -gt 0 ]]; then
		version_base="$major.x"
		wine_archive="wine-${version}.tar.xz"
	elif [[ $major -gt 1 && $minor -eq 0 ]]; then
		version_base=${version:0:3}
		wine_archive="wine-${version}.tar.xz"
	else
		version_base=${version:0:3}
		wine_archive="wine-${version}.tar.bz2"
	fi

	mkdir -p .cache
	if [ ! -f ".cache/$wine_archive" ]; then
		echo "Downloading Wine ${version}"
		wget http://dl.winehq.org/wine/source/$version_base/${wine_archive} -O .cache/${wine_archive}
	else
		echo "Wine ${version} already cached"
	fi
	tar xf .cache/$wine_archive
	if [ -d ${source_dir} ]; then
		rm -rf ${source_dir}
	fi
	mv wine-${version} ${source_dir}
}

DownloadWine

export BASEDIR=/home/vagrant/$bin_dir/
mkdir -p $BASEDIR

cd ${source_dir}
echo "Building $(git log -1)"
echo "---"

echo "Configuring 64 bit build"
mkdir -p build64
cd build64
LDFLAGS="-L${runtime_path}/lib64 -Wl,-rpath-link,${runtime_path}/lib64" ../configure -q -C --enable-win64 --libdir="$BASEDIR"/lib64 --bindir="$BASEDIR"/bin --datadir="$BASEDIR"/share --mandir="$BASEDIR"/share/man ${configure_opts}
CC="ccache gcc" CROSSCC="ccache x86_64-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib64 make -s -j$(nproc)
cd ..

echo "Configuring 32 bit build"
mkdir -p build32
cd build32
LDFLAGS="-L${runtime_path}/lib32 -Wl,-rpath-link,$runtime_path/lib32" ../configure -q -C --libdir="$BASEDIR"/lib --bindir="$BASEDIR"/bin --datadir="$BASEDIR"/share --mandir="$BASEDIR"/share/man ${configure_opts}
CC="ccache gcc" CROSSCC="ccache i686-w64-mingw32-gcc" LD_LIBRARY_PATH=${runtime_path}/lib32 make -s -j$(nproc)
cd ..

export DESTDIR=/vagrant/runners/wine/
mkdir -p $DESTDIR
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

echo "Copying 32 bit runtime libraries to build"
#copy sdl2, faudio, vkd3d, and ffmpeg libraries
cp -R "$runtime_path"/lib32/* "$BASEDIR"/lib/

echo "Cleaning include files from build"
rm -rf "$BASEDIR"/include

echo "Copying wine-mono and wine-gecko to build"
if [ -d "$source_dir/lutris-patches/" ]; then
	cp -R "$source_dir/lutris-patches/mono" "$BASEDIR"/
	cp -R "$source_dir/lutris-patches/gecko" "$BASEDIR"/
fi

echo "Creating tarball from build at $BASEDIR"
cd ~ && tar cvJf ${archive_filename} ${bin_dir}
sudo mv ${archive_filename} $DESTDIR

echo "Build complete!"
