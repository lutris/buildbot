FROM i386/ubuntu:18.04


RUN apt-get update && apt-get install -y git cmake wx3.0-headers \
        libaio-dev libasound2-dev libbz2-dev libgl1-mesa-dev \
        libglu1-mesa-dev libgtk2.0-dev libpng-dev libpng++-dev \
        libpulse-dev libsdl2-dev \
        libsoundtouch-dev libwxbase3.0-dev libwxgtk3.0-dev libx11-dev \
        portaudio19-dev zlib1g-dev liblzma-dev \
        libcg libglew-dev libsparsehash-dev

RUN mkdir /build
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build

CMD ["/build/build.sh"]
