function clone {
    local repo_url=$1
    local source_dir=$2
    local recurse=$3
    local tag=$4

    if [ "$recurse" ]; then
        recurse="--recursive"
    else
        recurse=""
    fi
    if [ -d ${source_dir} ]; then
        echo "Updating sources"
        cd ${source_dir}
        git checkout master
        git clean -dfx
        git reset --hard
        git pull origin master
        cd ..
    else
        echo "Cloning sources"
        git clone ${recurse} ${repo_url} ${source_dir}
    fi
    if [ "$tag" ]; then
        cd ${source_dir}
        git checkout ${tag}
        cd ..
    fi
}

function install_deps {
    echo "Installing $@"
    sudo DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -y --yes $@
}
