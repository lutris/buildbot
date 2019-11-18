#!/bin/bash

set -e
lib_path="../lib/"
source ${lib_path}upload_handler.sh

# Lutris runtime
runtime_dir="$(lsb_release -is)-$(lsb_release -rs)-$(uname -m)"
rm -rf ${runtime_dir}
mkdir -p ${runtime_dir}
python3 lutrisrt.py
mv runtime/* ${runtime_dir}

# Copy Lutris runtime extra libs
cp -a extra/${runtime_dir}/* ${runtime_dir}

runtime_archive="${runtime_dir}.tar.xz"
echo "Compressing runtime $runtime_archive..."
tar cJf ${runtime_archive} ${runtime_dir}
runtime_upload ${runtime_dir} ${runtime_archive}
