function clone {
    repo_url=$1
    source_dir=$2
    recurse=$3

    if [ "$recurse" ]; then
        recurse="--recursive"
    else
        recurse=""
    fi
    if [ -d ${source_dir} ]; then
        echo "Updating sources"
        cd ${source_dir}
        git checkout master
        git pull
    else
        echo "Cloning sources"
        git clone ${recurse} ${repo_url} ${source_dir}
        cd $source_dir
    fi
}

function install_deps {
    echo "Installing $@"
    sudo DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -y --force-yes $@
}
