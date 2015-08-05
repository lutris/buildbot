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
    #host="http://localhost:8000"
    host="https://lutris.net"

    upload_url="${host}/api/runners/${runner}/versions"
    access_token=$(cat ../../.lutris_token)
    content_type="multipart/form-data"

    curl \
        -v \
        --request POST \
        --header "Authorization: Token $access_token" \
        --form "version=${version}" \
        --form "architecture=${architecture}" \
        --form "file=@${filename}" \
        "$upload_url"
}
