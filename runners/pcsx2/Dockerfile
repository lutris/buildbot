FROM i386/ubuntu:18.04


RUN apt-get update && apt-get install -y git cmake wx3.0-headers coreutils \
        libaio-dev libasound2-dev libbz2-dev libgl1-mesa-dev \
        libglu1-mesa-dev libgtk2.0-dev libpng-dev libpng++-dev \
        libpulse-dev libsdl2-dev libgtk-3-dev libx11-xcb-dev \
        libsoundtouch-dev libwxbase3.0-dev libwxgtk3.0-dev libx11-dev \
        portaudio19-dev zlib1g-dev liblzma-dev libsamplerate0-dev \
        libpcap0.8-dev libwxgtk3.0-gtk3-dev libxml2-dev locales \
        libcg libglew-dev libsparsehash-dev libfmt-dev sudo libcap2-bin

RUN mkdir /build
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build

CMD ["/build/build.sh"]
