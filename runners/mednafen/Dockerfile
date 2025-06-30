FROM registry.gitlab.steamos.cloud/proton/sniper/sdk:latest


RUN mkdir -p /build/artifacts
WORKDIR /build
COPY lib /build/lib
COPY build.sh /build
RUN apt update
CMD ["/build/build.sh"]

