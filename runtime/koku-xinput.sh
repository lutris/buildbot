#!/bin/bash

set -e

git clone https://github.com/KoKuToru/koku-xinput-wine.git
cd koku-xinput-wine
cmake .
make
cp koku-xinput-wine.so ../extra/lib32/koku-xinput-wine/
cd ..
rm -rf koku-xinput-wine

git clone https://github.com/gabomdq/SDL_GameControllerDB
cd SDL_GameControllerDB
cp gamecontrollerdb.txt ../extra/lib32/koku-xinput-wine/
cd ..
rm -rf SDL_GameControllerDB
