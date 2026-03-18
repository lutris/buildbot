FROM registry.gitlab.steamos.cloud/proton/sniper/sdk:latest

RUN dpkg --add-architecture i386
RUN mkdir -p /build/artifacts
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build/
RUN apt update
RUN apt-get install -y gcc-i686-linux-gnu g++-i686-linux-gnu cmake \
    libsdl2-dev:i386 libgl-dev:i386 pkg-config:i386
CMD ["/build/build.sh"]
