FROM ubuntu:trusty

# Install any global dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake git wget curl python

# Set up the entry point script
COPY ./Dockerfile-entrypoint.sh /
ENTRYPOINT ["/Dockerfile-entrypoint.sh"]
RUN chmod +x /Dockerfile-entrypoint.sh

# Default value for wine-staging build
ENV STAGING 0

# Set up the application directory
VOLUME ["/buildbot"]
WORKDIR /buildbot
