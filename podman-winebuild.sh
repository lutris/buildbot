#!/bin/bash

# usage: ./podman-winebuild.sh name winerepo branch
# example: ./podman-winebuild.sh lutris https://github.com/GloriousEggroll/proton-wine GE-Proton8-15
# build name output: vagrant_share/wine-lutris-GE-Proton8-15-x86_64.tar.xz

if [[ ! -d vagrant_share ]]; then
	mkdir -p vagrant_share
fi
if [[ -z $(podman container list -a | grep buildbot) ]]; then
	podman create --interactive --name buildbot --mount type=bind,source="$PWD"/vagrant_share,destination=/vagrant,rw=true docker.io/gloriouseggroll/lutris_buildbot:bookworm
fi

podman start buildbot

# cleanup any old builds first
podman exec buildbot bash -c "cd /home/vagrant/lutris-buildbot && git config --global --add safe.directory /home/vagrant/lutris-buildbot"
podman exec buildbot bash -c "cd /home/vagrant/lutris-buildbot && git reset --hard HEAD && git clean -xdf && git pull"
podman exec buildbot bash -c "rm -Rf /home/vagrant/lutris-buildbot/runners/wine/wine-src/"

# start build
podman exec buildbot bash -c "cd /home/vagrant/lutris-buildbot/runners/wine && ./build.sh --as $1 --version $3 --with $2 --branch $3"

podman stop buildbot

