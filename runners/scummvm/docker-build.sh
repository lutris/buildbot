cp -a ../../lib .
docker build -t scummvmbuild .
docker run \
    --rm -it --name scummvm \
    --mount type=bind,source="$(pwd)/build",target=/build/artifacts \
    scummvmbuild

