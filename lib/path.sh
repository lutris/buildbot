
function get_script_dir {
    script_path="$(readlink -f $0)"
    script_dir="$(dirname $script_path)"
    echo $script_dir
}

function get_runner {
    echo $(basename $(get_script_dir))
}
