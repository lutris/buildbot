#!/bin/bash

set -e

params=$(getopt -n $0 -o v:s:r:f: --long version:,staging-patch-override:,remote:,flavour: -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -v|--version) version=$2; shift 2 ;;
        -r|--remote) remote=$2; shift 2 ;;
        -f|--flavour) flavour=$2; shift 2 ;;
        *) shift; break ;;
    esac
done

root_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ $flavour ]; then
  infix="$flavour-"
fi
branch_name=lutris-"$infix""$version"
wine_source_dir="${root_dir}/wine"

GetSources() {
    if [ ! -d "${root_dir}/wine/" ]; then
      git clone https://github.com/lutris/wine.git "${root_dir}/wine"
    fi
    if [ -d "${root_dir}/wine-staging/" ]; then
      git -C "${root_dir}/wine-staging/" fetch
      git -C "${root_dir}/wine-staging/" reset --hard origin/master
    else
      git clone https://github.com/wine-staging/wine-staging.git "${root_dir}/wine-staging/"
    fi
    if [ -d "${root_dir}/PKGBUILDS/" ]; then
      git -C "${root_dir}/PKGBUILDS/" fetch
      git -C "${root_dir}/PKGBUILDS/" reset --hard origin/master
      git -C "${root_dir}/PKGBUILDS/" clean -fx
    else
      git clone https://github.com/Tk-Glitch/PKGBUILDS.git "${root_dir}/PKGBUILDS/"
    fi
}

PrepareWineVersion() {
    if [[ "$wine_source_dir" ]]; then
        git -C "$wine_source_dir" clean -fx
    fi
    if [[ `git -C "$wine_source_dir" branch -v | grep -w -o "$branch_name"-old` ]]; then
        git -C "$wine_source_dir" reset --hard
        git -C "$wine_source_dir" checkout $branch_name
        git -C "$wine_source_dir" branch -D "$branch_name"-old
    fi
    if [[ `git -C "$wine_source_dir" branch -v | grep -w -o "$branch_name"` ]]; then
        git -C "$wine_source_dir" branch -m "$branch_name" "$branch_name"-old
    fi
    if [[ ! `git -C "$wine_source_dir" remote -v | grep -m 1 -o winehq-github` ]]; then
        git -C "$wine_source_dir" remote add winehq-github https://github.com/wine-mirror/wine.git
    fi
      git -C "$wine_source_dir" fetch winehq-github master:$branch_name
      git -C "$wine_source_dir" reset --hard
      git -C "$wine_source_dir" checkout $branch_name
      git -C "$wine_source_dir" reset --hard "wine-$version"
    if [[ `git -C "$wine_source_dir" branch -v | grep -w -o "$branch_name"-old` ]]; then
          git -C "$wine_source_dir" branch -D "$branch_name"-old
    fi
    git -C "$wine_source_dir" clean -df

    git -C "${root_dir}/wine-staging/" reset --hard "v$version"
}


ApplyStagingPatches() {
    if [ $flavour ]; then
    override_preset=$(cat "${root_dir}/$flavour.override-preset")
    "${root_dir}/wine-staging/patches/patchinstall.sh" DESTDIR="$wine_source_dir" --all --no-autoconf $override_preset
    else
    "${root_dir}/wine-staging/patches/patchinstall.sh" DESTDIR="$wine_source_dir" --all --no-autoconf
    fi
    cd "$wine_source_dir"
    git add .
    git commit -am "Add Staging patches"
}

ConfigureTKG() {
    git -C "${root_dir}/PKGBUILDS/" clean -df
    sed -i s@"_EXT_CONFIG_PATH=~/.config/frogminer/wine-tkg.cfg"@"_EXT_CONFIG_PATH=${root_dir}/PKGBUILDS/wine-tkg.cfg"@g "${root_dir}/PKGBUILDS/wine-tkg-git/customization.cfg"
    cp "${root_dir}/"$infix"wine-tkg.cfg" "${root_dir}/PKGBUILDS/wine-tkg.cfg"
    sed -i s/WINEVERSION/"v$version"/g "${root_dir}/PKGBUILDS/wine-tkg.cfg"
    cp "${root_dir}"/"$infix"patches/*.mypatch "${root_dir}/PKGBUILDS/wine-tkg-git/wine-tkg-userpatches/"
}

PrepareTKGSource() {
    cd "${root_dir}/PKGBUILDS/wine-tkg-git/"
    chmod +x "${root_dir}/PKGBUILDS/wine-tkg-git/non-makepkg-build.sh"
    "${root_dir}/PKGBUILDS/wine-tkg-git/non-makepkg-build.sh" || true
    find "${root_dir}/PKGBUILDS/wine-tkg-git/src/wine-mirror-git/" -name \*.orig -type f -delete
    rm -rf "${root_dir}/PKGBUILDS/wine-tkg-git/src/wine-mirror-git/autom4te.cache"
}
CommitTKGSource() {
    cd "$wine_source_dir"
    git -C "$wine_source_dir" rm -rf "$wine_source_dir"/*
    cp -R "${root_dir}/PKGBUILDS/wine-tkg-git/src/wine-mirror-git/"[!.]* "$wine_source_dir"
    cp -R ""${root_dir}"/"$infix"patches/" "$wine_source_dir/lutris-patches/"
    if [[ `ls -R | grep .rej ` ]]; then
        echo Rejects were found! Aborting.
        exit
      else
        git add .
        git commit -am "lutris-"$infix""$version", generated with Tk-Glitch/PKGBUILDS"
    fi
}

if [ "$version" ]; then
    GetSources
    PrepareWineVersion
    ApplyStagingPatches
    ConfigureTKG
    PrepareTKGSource
    CommitTKGSource
else
    echo No version is specified! Aborting.
    exit
fi
