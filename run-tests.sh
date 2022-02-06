#!/bin/sh
# Run every available test - Bash needed

THISDIR="$(realpath "$(dirname "$0")")"

cd "$THISDIR/test"
for test in *test;
do
	echo "Running test $test ..."
	bash "$test" || { echo "*** ERROR: Test '$test' failed!"; exit 1; }
done
