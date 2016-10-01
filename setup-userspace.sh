#!/bin/bash

set -e

if [ ! -d ".dotfiles" ]; then
    git clone https://github.com/strycore/dotfiles .dotfiles
    cd .dotfiles
    ./install.sh
    ./install.sh
    cd
fi

git clone https://github.com/lutris/buildbot.git
