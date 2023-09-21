#!/bin/bash
# Script to setup tools for uploading files

set -e

# Install Doctl
DOCTL_VERSION="1.98.1"
wget https://github.com/digitalocean/doctl/releases/download/v$DOCTL_VERSION/doctl-$DOCTL_VERSION-linux-amd64.tar.gz
tar xf doctl-$DOCTL_VERSION-linux-amd64.tar.gz
sudo mv doctl /usr/local/bin
rm doctl-$DOCTL_VERSION-linux-amd64.tar.gz
