cp -a ../../lib .
mkdir -p build
chcon -Rt svirt_sandbox_file_t build
docker build -t freesynd-build .
rm -rf ./lib
docker run \
    --rm -it --name freesynd \
    --mount type=bind,source="$(pwd)/build",target=/build/artifacts \
    freesynd-build
