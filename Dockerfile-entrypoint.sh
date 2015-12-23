#!/bin/bash
set -e

# Switch to the given directory to build in
cd $1
exec ./build.sh
