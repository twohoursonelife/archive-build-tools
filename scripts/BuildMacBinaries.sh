#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;

cd repos/OneLife;

./configure 2;

cd gameSource;

export CUSTOM_MACOSX_LINK_FLAGS="-F /Library/Frameworks";
sed -Ei -e 's#/usr/lib/libz.a#/usr/local/opt/zlib/lib/libz.a#' Makefile
sed -Ei -e 's#/usr/lib/libpng.a#/usr/local/lib/libpng.a#' Makefile

[[ -e Crucible ]] && rm Crucible;

make;

./makeEditor.sh;

cd ../server;

./configure 2;

[[ -e CrucibleServer ]] && rm CrucibleServer;

make;