#!/bin/sh
#
# Create a distributable archive of the current version of Makeself

VER=`cat VERSION`
mkdir -p /tmp/makeself-$VER release
cp -pPR makeself* README.md COPYING VERSION /tmp/makeself-$VER/
./makeself.sh --notemp /tmp/makeself-$VER release/makeself-$VER.run "Makeself v$VER" echo "Makeself has extracted itself" 

