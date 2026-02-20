FROM registry.gitlab.steamos.cloud/proton/sniper/sdk:latest


RUN mkdir -p /build/artifacts
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build
RUN apt update
RUN apt-get install -y cmake gettext libgtkmm-3.0-dev libsdl2-dev libxrandr-dev libx11-dev libxext-dev portaudio19-dev libasound2-dev libpulse-dev libwayland-dev libwayland-egl1 libminizip-dev
CMD ["/build/build.sh"]
