#!/bin/bash

set -e

params=$(getopt -n $0 -o v:r:f:s:d:u:t:n --long version:,remote:,flavour:,staging-override:,disabled-patchset:,update-number:,staging-version:,noupload -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -v|--version) version=$2; shift 2 ;;
        -r|--remote) remote=$2; shift 2 ;;
        -f|--flavour) flavour=$2; shift 2 ;;
        -s|--staging-override) staging_version_override=$2; shift 2 ;;
        -d|--disabled-patchset) disabled_patchset=$2; shift 2 ;;
        -u|--update-number) branch_update="-$2"; shift 2 ;;
        -t|--staging-version) staging_version="v$2"; shift 2 ;;
        -n|--noupload) noupload=1; shift ;;
        *) shift; break ;;
    esac
done

root_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ $flavour ]; then
  infix="$flavour-"
  suffix="-$flavour"
fi

if [ ! $staging_version ]; then
  staging_version="v$version"
fi

if [ $flavour ]; then
  prefix_override_preset=$flavour
else
  prefix_override_preset="wine"
fi
if [ -e "${root_dir}/$prefix_override_preset.override-preset" ]; then
disabled_patchset="$(cat "${root_dir}/$prefix_override_preset.override-preset") $disabled_patchset"
fi

branch_name=lutris-"$infix""$version""$branch_update"
wine_source_dir="${root_dir}/wine-src"
wine_staging_source_dir="${root_dir}/wine-staging-src"

GetSources() {
    if [ ! -d "${wine_source_dir}" ]; then
      git clone https://github.com/lutris/wine.git "${wine_source_dir}"
    fi
    if [ -d "${wine_staging_source_dir}" ]; then
      git -C "${wine_staging_source_dir}" fetch
      git -C "${wine_staging_source_dir}" reset --hard origin/master
    else
      git clone https://github.com/wine-staging/wine-staging.git "${wine_staging_source_dir}"
    fi
}

PrepareWineVersion() {
    if [ "$wine_source_dir" ]; then
        git -C "$wine_source_dir" clean -dfx
    fi
    if [ $(git -C "$wine_source_dir" branch -v | grep -o -E "$branch_name-old\s+") ]; then
        git -C "$wine_source_dir" reset --hard
        git -C "$wine_source_dir" checkout $branch_name
        git -C "$wine_source_dir" branch -D "$branch_name"-old
    fi
    if [ $(git -C "$wine_source_dir" branch -v | grep -o -E "$branch_name\s+") ]; then
        git -C "$wine_source_dir" branch -m "$branch_name" "$branch_name"-old
    fi
    if [ ! $(git -C "$wine_source_dir" remote -v | grep -m 1 -o winehq-github) ]; then
        git -C "$wine_source_dir" remote add winehq-github https://github.com/wine-mirror/wine.git
    fi
      git -C "$wine_source_dir" fetch winehq-github master:$branch_name
      git -C "$wine_source_dir" reset --hard
      git -C "$wine_source_dir" checkout $branch_name
      git -C "$wine_source_dir" reset --hard "wine-$version"
    if [ $(git -C "$wine_source_dir" branch -v | grep -o -E "$branch_name-old\s+") ]; then
          git -C "$wine_source_dir" branch -D "$branch_name"-old
    fi
    git -C "$wine_source_dir" clean -dfx

    if [ $staging_version_override ]; then
      git -C "${wine_staging_source_dir}" reset --hard "$staging_version_override"
    else
      git -C "${wine_staging_source_dir}" reset --hard "$staging_version"
    fi
}

PrepareSource() {
"$root_dir"/patches/prepare"$suffix".sh
find "${root_dir}/wine-src" -name \*.orig -type f -delete
}

CommitSource() {
    cd "$wine_source_dir"

    cp -R ""${root_dir}"/patches/" "$wine_source_dir/lutris-patches/"
    if [ "$(ls -R | grep .rej)" ]; then
        echo Rejects were found! Aborting.
        exit
      else
        git add .
        git commit -am "${branch_name}"
    fi
    if [ ! $noupload ]; then
    git -C "$wine_source_dir" push --force origin ${branch_name}
    fi
}

if [ "$version" ]; then
    GetSources
    PrepareWineVersion
    PrepareSource
    CommitSource
else
    echo No version is specified! Aborting.
    exit
fi