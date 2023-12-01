#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive;
echo 'path-exclude=/usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/99-exclude-cruft
echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/99-exclude-cruft
echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/99-exclude-cruft
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf
echo '#!/bin/sh' > /usr/sbin/policy-rc.d
echo 'exit 101' >> /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
dpkg --add-architecture i386
apt-get update

# Wine dependencies
apt-get install -y gcc gcc-mingw-w64-x86-64 gcc-mingw-w64-i686 gcc-multilib \
                git sudo autoconf flex bison perl gettext \
                libasound2-dev:amd64 libasound2-dev:i386 \
                libcapi20-dev:amd64 libcapi20-dev:i386 \
                libcups2-dev:amd64 libcups2-dev:i386 \
                libdbus-1-dev:amd64 libdbus-1-dev:i386 \
                libfontconfig-dev:amd64 libfontconfig-dev:i386 \
                libfreetype-dev:amd64 libfreetype-dev:i386 \
                libgl1-mesa-dev:amd64 libgl1-mesa-dev:i386 \
                libgnutls28-dev:amd64 libgnutls28-dev:i386 \
                libgphoto2-dev:amd64 libgphoto2-dev:i386 \
                libice-dev:amd64 libice-dev:i386 \
                libkrb5-dev:amd64 libkrb5-dev:i386 \
                libosmesa6-dev:amd64 libosmesa6-dev:i386 \
                libpcap-dev:amd64 libpcap-dev:i386 \
                libpcsclite-dev:amd64 \
                libpulse-dev:amd64 libpulse-dev:i386 \
                libsane-dev:amd64 libsane-dev:i386 \
                libsdl2-dev:amd64 libsdl2-dev:i386 \
                libudev-dev:amd64 libudev-dev:i386 \
                libusb-1.0-0-dev:amd64 libusb-1.0-0-dev:i386 \
                libv4l-dev:amd64 libv4l-dev:i386 \
                libvulkan-dev:amd64 libvulkan-dev:i386 \
                libwayland-dev:amd64 libwayland-dev:i386 \
                libx11-dev:amd64 libx11-dev:i386 \
                libxcomposite-dev:amd64 libxcomposite-dev:i386 \
                libxcursor-dev:amd64 libxcursor-dev:i386 \
                libxext-dev:amd64 libxext-dev:i386 \
                libxi-dev:amd64 libxi-dev:i386 \
                libxinerama-dev:amd64 libxinerama-dev:i386 \
                libxrandr-dev:amd64 libxrandr-dev:i386 \
                libxrender-dev:amd64 libxrender-dev:i386 \
                libxxf86vm-dev:amd64 libxxf86vm-dev:i386 \
                linux-libc-dev:amd64 linux-libc-dev:i386 \
                ocl-icd-opencl-dev:amd64 ocl-icd-opencl-dev:i386 \
                samba-dev:amd64 \
                unixodbc-dev:amd64 unixodbc-dev:i386 \
                gudev-1.0:amd64 gudev-1.0:i386 \
                libgcrypt-dev libgpg-error-dev \
                x11proto-dev
# More wine dependencies
apt-get install -y ccache netbase curl ca-certificates xserver-xorg-video-dummy xserver-xorg xfonts-base xinit fvwm \
                    winbind fonts-liberation2 fonts-noto-core fonts-noto-cjk pulseaudio libdrm-dev:amd64 libdrm-dev:i386
# Gstreamer codecs
curl -O https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb
dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
echo 'deb https://www.deb-multimedia.org bullseye main' >> /etc/apt/sources.list
rm deb-multimedia-keyring_2016.8.1_all.deb
apt-get update
apt-get install -y libgstreamer-plugins-base1.0-dev:amd64 libgstreamer-plugins-base1.0-dev:i386 \
                    libasound2-plugins:amd64 libasound2-plugins:i386 \
                    libmjpegutils-2.1-0:amd64 libmjpegutils-2.1-0:i386 \
                    gstreamer1.0-libav:amd64 gstreamer1.0-libav:i386 \
                    gstreamer1.0-plugins-base:amd64 gstreamer1.0-plugins-good:amd64 gstreamer1.0-plugins-bad:amd64 gstreamer1.0-plugins-ugly:amd64 \
                    gstreamer1.0-plugins-base:i386 gstreamer1.0-plugins-good:i386 gstreamer1.0-plugins-bad:i386 gstreamer1.0-plugins-ugly:i386 && \
# Misc utilities (not sure if fontconfig is required)
apt-get -y install wget build-essential vim nano fontconfig
# Runtime dependencies
apt-get -y install lsb-release
apt-get clean

# Set root shell as bash
usermod -s /bin/bash root

if [[ -z $(cat /etc/passwd | grep vagrant) ]]; then
	# Setup vagrant user in case it doesnt exist yet
	useradd -m -s /bin/bash -G sudo vagrant

	# Set password for vagrant user if it's not done yet
	echo -e 'vagrant\nvagrant\n' | passwd vagrant
fi
