#!/bin/bash

# usage: ./makebuild.sh name winerepo branch
# example: ./makebuild.sh lutris https://github.com/GloriousEggroll/proton-wine GE-Proton8-15
# build name output: wine-lutris-GE-Proton8-15-x86_64.tar.xz

vagrant up

# cleanup any old builds first
vagrant ssh -c "cd lutris-buildbot && git reset --hard HEAD && git clean -xdf && git pull"
vagrant ssh -c "rm -Rf lutris-buildbot/runners/wine/wine-src/"

# start build
vagrant ssh -c "cd lutris-buildbot/runners/wine && ./build.sh --as $1 --version $3 --with $2 --branch $3 --useccache --usemingw"

vagrant halt


