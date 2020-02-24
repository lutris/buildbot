#!/bin/bash

if [ ! -d ".dotfiles" ]; then
    git clone https://github.com/strycore/dotfiles dotfiles
    cd dotfiles
    ./install.sh
    cd
fi