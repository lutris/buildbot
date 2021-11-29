#!/bin/bash

set -e

sudo apt update
sudo apt -y full-upgrade

git reset --hard HEAD
git clean -xdf
git pull origin master