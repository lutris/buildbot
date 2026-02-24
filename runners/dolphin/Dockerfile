FROM registry.gitlab.steamos.cloud/proton/sniper/sdk:latest


RUN mkdir -p /build/artifacts
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build
RUN echo "deb http://archive.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list
RUN apt update
RUN apt-get install -y build-essential cmake libevdev-dev libusb-1.0-0-dev libxrandr-dev libxi-dev \
    libpangocairo-1.0-0 libbluetooth-dev libasound2-dev \
    libpulse-dev libgl1-mesa-dev libcurl4-openssl-dev libudev-dev libsystemd-dev
RUN apt-get install -y -t bullseye-backports qt6-base-private-dev libqt6svg6-dev
CMD ["/build/build.sh"]
