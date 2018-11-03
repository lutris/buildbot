#!/bin/bash

spaces_upload() {
    filename=$1
    destination=$2
    aws s3 --endpoint-url=https://nyc3.digitaloceanspaces.com cp ${filename} s3://lutris/${destination}/${filename}
    s3cmd setacl s3://lutris/${destination}/${filename} --acl-public
}

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

    token_path="../../.lutris_token"
    if [ ! -f $token_path ]; then
        echo "You are not authenticated, runner won't upload"
        return
    fi
    access_token=$(cat $token_path)

    if [[ "$4" == http* ]]; then
        url=$4
    else
        filename=$4
    fi

    host="https://lutris.net"
    upload_url="${host}/api/runners/${runner}/versions"
    echo "Uploading to ${upload_url}"
    if [[ "$url" == http* ]]; then
        curl \
            -v \
            --request POST \
            --header "Authorization: Token $access_token" \
            --form "version=${version}" \
            --form "architecture=${architecture}" \
            --form "url=${url}" \
            "$upload_url"
    else
        curl \
            -v \
            --request POST \
            --header "Authorization: Token $access_token" \
            --form "version=${version}" \
            --form "architecture=${architecture}" \
            --form "file=@${filename}" \
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

    host="https://lutris.net"
    upload_url="${host}/api/runtime"
    echo "Uploading to ${upload_url}"
    url="https://lutris.nyc3.digitaloceanspaces.com/runtime/${name}.tar.bz2"

    curl \
        -v \
        --request POST \
        --header "Authorization: Token $access_token" \
        --form "name=${name}" \
        --form "url=${url}" \
        "$upload_url"
}
