cp -a ../../lib .
mkdir -p build
chcon -Rt svirt_sandbox_file_t build
docker build -t dolphinbuild .
rm -rf ./lib
docker run \
    --rm -it --name dolphin \
    --mount type=bind,source="$(pwd)/build",target=/build/artifacts \
    dolphinbuild

