#!/bin/sh
#
# Create a distributable archive of the current version of Makeself

VER=`cat VERSION`
mkdir /tmp/makeself-$VER
cp -a makeself* test README.md COPYING VERSION .gitmodules /tmp/makeself-$VER/
./makeself.sh --notemp /tmp/makeself-$VER makeself-$VER.run "Makeself v$VER" echo "Makeself has extracted itself" 

