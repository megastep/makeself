#!/bin/sh
set -eu
THIS="$(readlink -f "$0")"
THISDIR="$(dirname "${THIS}")"

# Run every available test

echo ">> env:"
uname -a

cd "$THISDIR"

bash "./run-testlinter.sh"

for test in ./*test;
do
	echo "::group::$test"
	bash "./$test" || { echo "*** ERROR: Test '$test' failed!"; exit 1; }
	echo "::endgroup::"
done
