#!/bin/bash

# usage: ./vagrant-winebuild.sh name winerepo branch
# example: ./vagrant-winebuild.sh lutris-GE https://github.com/GloriousEggroll/proton-wine Proton8-15
# build name output: vagrant_share/wine-lutris-GE-Proton8-15-x86_64.tar.xz

vagrant up

# cleanup any old builds first
vagrant ssh -c "rm -Rf buildbot/runners/wine/wine-src/"

# start build
vagrant ssh -c "cd buildbot/runners/wine && ./build.sh --as $1 --version $3 --with $2 --branch $3"

vagrant halt


