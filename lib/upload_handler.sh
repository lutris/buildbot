#!/bin/bash

runner_upload() {
    runner=$1
    version=$2
    architecture=$3
    if [[ "$architecture" == "i686" ]]; then
        architecture="i386"
    fi
    if [[ "$architecture" == "armv7l" ]]; then
        architecture="armv7"
    fi

    filename=$4

    token_path="../../.lutris_token"
    if [ ! -f $token_path ]; then
        echo "You are not authenticated, runner won't upload"
        return
    fi
    access_token=$(cat $token_path)

    host="https://lutris.net"
    upload_url="${host}/api/runners/${runner}/versions"
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

runtime_upload() {
    name=$1
    filename=$2

    token_path="../.lutris_token"
    if [ ! -f $token_path ]; then
        echo "You are not authenticated, runner won't upload"
        return
    fi
    access_token=$(cat $token_path)

    host="https://lutris.net"
    upload_url="${host}/api/runtime"
    echo "Uploading to ${upload_url}"
    curl \
        -v \
        --request POST \
        --header "Authorization: Token $access_token" \
        --form "name=${name}" \
        --form "file=@${filename}" \
        "$upload_url"
}
