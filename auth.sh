#!/bin/bash

token_url="https://lutris.net/api/accounts/token"


read -p "Username: " username
read -s -p "Password: " password

access_token=$(
    curl ${token_url} --silent --data "username=${username}" --data "password=${password}" \
        | cut --delimiter=: --fields=2 \
        | tr --delete '\"}[]'
)

echo ""

if [[ "$access_token" == *"Unable"* ]]; then
    echo "Auth failed:" $access_token
else
    echo "Login successful"
    echo $access_token >> .lutris_token
fi
