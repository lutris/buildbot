cp -a ../../lib .
mkdir -p build
chcon -Rt svirt_sandbox_file_t build
docker build -t acgc-pc-port-build .
rm -rf ./lib
docker run \
    --rm -it --name acgc-pc-port \
    --mount type=bind,source="$(pwd)/build",target=/build/artifacts \
    acgc-pc-port-build
