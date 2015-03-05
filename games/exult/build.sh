#!/bin/bash
sourcedir=exult-code
#svn checkout svn://svn.code.sf.net/p/exult/code/exult/trunk $sourcedir
cd $sourcedir
sudo apt-get install -y libglade2-dev
./autogen.sh
./configure --enable-exult-studio
make
