#!/bin/bash

# usage: ./makebuild.sh name winerepo branch
# example: ./makebuild.sh lutris http://github.com/gloriouseggroll/wine ge-5.2
# build name output: wine-lutris-ge-5.2-x86_64.tar.xz

vagrant up

# cleanup any old builds first
vagrant ssh -c "cd lutris-buildbot && git reset --hard HEAD && git clean -xdf && git pull"
vagrant ssh -c "rm -Rf lutris-buildbot/runners/wine/wine-src/"

# start build
vagrant ssh -c "cd lutris-buildbot/runners/wine && ./vanilla-build.sh --as $1 --version $3 --with $2 --branch $3 --useccache --usemingw"

vagrant halt


