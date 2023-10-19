# This is used for creating new buildbot docker images (for example when we want to change the buildbot container/VM host distro)
# Currently based off debian 11 bullseye
#
# ATTENTION:
# You must prepare podman to be able to login to docker hub before attempting to push images
# Create an account then create a token
# https://hub.docker.com/settings/security?generateToken=true
#
# Then:
# podman login docker.io
# Username: <username>
# Password: <token>

#!/bin/bash
docker pull debian:bullseye
docker create --interactive --name bullseye debian:bullseye
docker start bullseye
docker cp ../../setup-buildbot.sh bullseye:/
docker exec bullseye bash -c "./setup-buildbot.sh"
docker exec bullseye bash -c "rm setup-buildbot.sh"
docker stop bullseye

# Change gloriouseggroll/lutris_buildbot:bullseye to your Docker repo and tag
docker commit bullseye gloriouseggroll/lutris_buildbot:bullseye
docker push gloriouseggroll/lutris_buildbot:bullseye

