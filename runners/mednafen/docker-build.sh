cp -a ../../lib .
mkdir -p build
chcon -Rt svirt_sandbox_file_t build
docker build -t mednafenbuild .
rm -rf ./lib
docker run \
    --rm -it --name mednafen \
    --mount type=bind,source="$(pwd)/build",target=/build/artifacts \
    mednafenbuild

