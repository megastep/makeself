#!/bin/sh
set -eu
THIS="$(realpath "$0")"
THISDIR="$(dirname "${THIS}")"
SRCDIR="$(dirname "${THISDIR}")"
VERSION="$(cat "${SRCDIR}/VERSION")"

# Test run on artifacts

echo ">> env:"
uname -a

cd "$THISDIR"

sh "../build-ubuntu/makeself-$VERSION.run" --target ./tmp/makeself-ubuntu
sh "../build-alpine/makeself-$VERSION.run" --target ./tmp/makeself-alpine
sh "../build-windows/makeself-$VERSION.run" --target ./tmp/makeself-windows
sh "../build-macos/makeself-$VERSION.run" --target ./tmp/makeself-macos