#!/bin/bash

set -e

pkg_name="reicast"
version="0.0.1"
arch=$(uname -a)

root_dir="$(pwd)"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}"

git clone https://github.com/reicast/reicast-emulator.git ${source_dir}

