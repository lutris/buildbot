cp -a ../../lib .
mkdir -p build
chcon -Rt svirt_sandbox_file_t build
docker build -t snes9xbuild .
rm -rf ./lib
docker run \
    --rm -it --name snes9x \
    --mount type=bind,source="$(pwd)/build",target=/build/artifacts \
    snes9xbuild
