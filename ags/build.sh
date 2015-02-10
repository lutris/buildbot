#!/bin/bash

sudo apt-get install git debhelper build-essential pkg-config libaldmb1-dev libfreetype6-dev libtheora-dev libvorbis-dev libogg-dev

git clone git://github.com/adventuregamestudio/ags.git
cd ags
make --directory=Engine
