FROM ubuntu:18.04

RUN apt-get update && apt-get install -y git libgl1-mesa-dev \
        libglu1-mesa-dev libpng-dev libpng++-dev \
        libpulse-dev libsdl2-dev libsoundtouch-dev libx11-dev \
        zlib1g-dev liblzma-dev

RUN apt-get install -y wget libfreetype6-dev libjpeg-dev libtheora-dev
RUN mkdir /build
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build

CMD ["/build/build.sh"]
