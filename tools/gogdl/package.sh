#!/bin/bash
# Package gogdl (GOG depot downloader) from Heroic Games Launcher releases
# for distribution as a Lutris runtime component.
#
# The resulting tarballs extract to a "gogdl/" directory containing the binary,
# matching what the Lutris runtime system expects at ~/.local/share/lutris/runtime/gogdl/
#
# Builds both x86_64 and arm64 packages.

set -e

VERSION="${1:-1.2.1}"
PKG_DIR="gogdl"

for ASSET_ARCH in x86_64 arm64; do
    ASSET_NAME="gogdl_linux_${ASSET_ARCH}"
    URL="https://github.com/Heroic-Games-Launcher/heroic-gogdl/releases/download/v${VERSION}/${ASSET_NAME}"
    TARBALL="gogdl-${VERSION}-${ASSET_ARCH}.tar.xz"

    echo "Downloading gogdl v${VERSION} for ${ASSET_ARCH}..."
    wget -q --show-progress -O "${ASSET_NAME}" "${URL}"

    echo "Packaging ${TARBALL}..."
    rm -rf "${PKG_DIR}"
    mkdir -p "${PKG_DIR}"
    mv "${ASSET_NAME}" "${PKG_DIR}/gogdl"
    chmod +x "${PKG_DIR}/gogdl"

    tar cJf "${TARBALL}" "${PKG_DIR}"
    rm -rf "${PKG_DIR}"

    echo "Created ${TARBALL}"
done
