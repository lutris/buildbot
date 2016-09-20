#!/bin/bash

set -e

git clone https://github.com/strycore/dotfiles .dotfiles
cd .dotfiles
./install.sh
./install.sh
cd

git clone git@github.com:lutris/buildbot.git
