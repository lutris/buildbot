
cp -a ../../lib .
docker build -t pcsx2build .
docker run \
    --rm -it --name pcsx2 \
    --mount type=bind,source="$(pwd)/build",target=/build/artifacts \
    pcsx2build

