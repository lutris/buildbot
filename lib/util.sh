function clone {
    repo_url=$1
    source_dir=$2
    if [ -d ${source_dir} ]; then
        echo "Updating sources"
        cd ${source_dir}
        git checkout master
        git pull
    else
        echo "Cloning sources"
        git clone ${repo_url} ${source_dir}
        cd $source_dir
    fi
}

function install_deps {
    echo "Installing $@"
    sudo apt-get install $@
}
