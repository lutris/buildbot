#!/bin/bash

PWD=$(pwd)
export SUPERTUXKART_DATADIR="${PWD}/share/supertuxkart"
export LD_LIBRARY_PATH="${PWD}/lib:${LD_LIBRARY_PATH}"
bin/supertuxkart
