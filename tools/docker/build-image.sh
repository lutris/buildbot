# This is used for creating new buildbot docker images (for example when we want to change the buildbot container/VM host distro)
# Currently based off debian 12 bookworm
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
docker pull debian:bookworm
docker create --interactive --name bookworm debian:bookworm
docker start bookworm
docker cp ../../setup-buildbot.sh bookworm:/
docker exec bookworm bash -c "./setup-buildbot.sh"
docker exec bookworm bash -c "rm setup-buildbot.sh"
docker stop bookworm

# Change gloriouseggroll/lutris_buildbot:bookworm to your Docker repo and tag
docker commit bookworm gloriouseggroll/lutris_buildbot:latest
docker push gloriouseggroll/lutris_buildbot:latest
