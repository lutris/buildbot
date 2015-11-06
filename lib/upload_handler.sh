#!/bin/bash

function runner_upload {
    runner=$1
    version=$2
    architecture=$3
    if [[ "$architecture" == "i686" ]]; then
        architecture="i386"
    fi
    if [[ "$architecture" == "i686" ]]; then
        architecture="i386"
    fi

    filename=$4

    if [ ! -f ../../.lutris_token ]; then
        echo "You are not authenticated, runner won't upload"
        return
    fi
    
    access_token=$(cat ../../.lutris_token)

    host="https://lutris.net"

    upload_url="${host}/api/runners/${runner}/versions"
    content_type="multipart/form-data"

    echo "Uploading to ${upload_url}"

    curl \
        -v \
        --request POST \
        --header "Authorization: Token $access_token" \
        --form "version=${version}" \
        --form "architecture=${architecture}" \
        --form "file=@${filename}" \
        "$upload_url"
}
