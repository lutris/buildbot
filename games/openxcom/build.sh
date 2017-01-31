#!/bin/bash
SOURCEDIR=OpenXcom-src
if ! [ -d "$SOURCEDIR" ] ; then
	git clone https://github.com/SupSuper/OpenXcom.git $SOURCEDIR
fi
cd $SOURCEDIR
mkdir build; cd $_
cmake ../
#sudo apt-get install -y libglade2-dev ### FIXME needs actual dependancies
NUMCPUS=$(($(cat /proc/cpuinfo | grep processor | wc -l) + 1))
make -j $NUMCPUS
