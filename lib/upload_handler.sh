#!/bin/bash

function runner_upload {
    version=$1
    architecture=$2
    filename=$3
    #host="http://localhost:8000"
    host="https://lutris.net"

    upload_url="${host}/api/runners/${1}/versions"
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
