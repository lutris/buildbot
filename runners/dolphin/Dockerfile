FROM registry.gitlab.steamos.cloud/proton/sniper/sdk:latest


RUN mkdir /build
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build
RUN echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list
RUN apt update
RUN apt-get install -y -t bullseye-backports qt6-base-private-dev
#CMD ["/build/build.sh"]
CMD ["bash"]
