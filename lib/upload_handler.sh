#!/bin/bash

spaces_upload() {
    filename=$1
    type=$2
    subtype=$3
    if [ $subtype ]; then
        subtype="/$subtype"
    fi 

    aws s3 --endpoint-url=https://nyc3.digitaloceanspaces.com cp ${filename} s3://lutris/${type}$subtype/${filename}
    s3cmd setacl s3://lutris/${type}$subtype/${filename} --acl-public
}

s3cmd_check_existence() {
    filename=$1
    type=$2  
    subtype=$3
    if [ $subtype ]; then
        subtype="/$subtype"
    fi

    s3cmd ls s3://lutris/${type}$subtype/ | grep -o $filename
}

api_check_runner_existence() {
    host='https://lutris.net'
    runner=$1
    architecture=$2
    version=$3

    curl \
        --compressed \
        --false-start \
        --globoff \
        --location \
        --path-as-is \
        --request GET \
        --retry 3 \
        --silent \
        --tcp-fastopen \
        --url "${host}/api/runners/${runner}" | \

        sed -e 's/^.*"versions":\[\([^]]*\)\].*$/\1/' -e 's/^{//;s/}$//;s/},{/\
    /g' | \
        sed -n -e '/"version":"'"$(printf '%s' "${version}" | sed 's/[]\\/$*.^[]/\\&/g')"'"/{
            /"architecture":"'"$(printf '%s' "${architecture}" | sed 's/[]\\/$*.^[]/\\&/g')"'"/p
        }' | \
        grep -q -F '' && echo true || echo false
}

doctl_purge_cdn() {
    PATH=$PATH:/snap/bin
    filename=$1
    type=$2   
    subtype=$3
    if [ $subtype ]; then
        subtype="/$subtype"
    fi  

    case README in
        "$(ls ../. | grep -o README)")
        doctl_cdn_id_path="../.doctl_cdn_id"
        ;;
        "$(ls ../../. | grep -o README)")
        doctl_cdn_id_path="../../.doctl_cdn_id"
        ;;
        *)
        doctl_cdn_id_path="./.doctl_cdn_id"
        ;;
    esac

    if [ ! -e "$doctl_cdn_id_path" ]; then
        echo "Enter CDN ID. You can get it by running 'doctl compute cdn ls':"
        read id_input
        echo $id_input >> $doctl_cdn_id_path
        echo "CDN ID $id_input is cached into $doctl_cdn_id_path"
    fi
    
    doctl_cdn_id=$(cat $doctl_cdn_id_path)

    doctl compute cdn flush $doctl_cdn_id --files ${type}$subtype/${filename}
}

runner_upload() {
    runner=$1
    version=$2
    architecture=$3
    filename=$4
    if [[ "$architecture" == "i686" ]]; then
        architecture="i386"
    fi
    if [[ "$architecture" == "armv7l" ]]; then
        architecture="armv7"
    fi

    token_path="../../.lutris_token"
    if [ ! -f $token_path ]; then
        echo "You are not authenticated, runner won't upload"
        return
    fi
    access_token=$(cat $token_path)
    
    if [ $(s3cmd_check_existence $filename "runners" ${runner}) ]; then
        file_exists=yes
    fi
    spaces_upload $filename "runners" ${runner}
    if [ $file_exists ]; then
        doctl_purge_cdn $filename "runners" ${runner}
    fi
    url="https://lutris.nyc3.cdn.digitaloceanspaces.com/runners/${runner}/$filename"

    if [ $(api_check_runner_existence ${runner} $architecture $version) = false ]; then
        host="https://lutris.net"
        upload_url="${host}/api/runners/${runner}/versions"
        echo "Uploading to ${upload_url}"
        curl \
            -v \
            --request POST \
            --header "Authorization: Token $access_token" \
            --form "version=${version}" \
            --form "architecture=${architecture}" \
            --form "url=${url}" \
            "$upload_url"
    fi
}

runtime_upload() {
    name=$1
    filename=$2

    token_path="../.lutris_token"
    if [ ! -f $token_path ]; then
        echo "You are not authenticated, runner won't upload"
        return
    fi
    access_token=$(cat $token_path)

    echo "Uploading archive to Spaces"
    spaces_upload $filename "runtime"
    doctl_purge_cdn $filename "runtime"

    host="https://lutris.net"
    upload_url="${host}/api/runtime"
    echo "Uploading to ${upload_url}"
    url="https://lutris.nyc3.cdn.digitaloceanspaces.com/runtime/${name}.tar.xz"

    curl \
        -v \
        --request POST \
        --header "Authorization: Token $access_token" \
        --form "name=${name}" \
        --form "url=${url}" \
        "$upload_url"
}
