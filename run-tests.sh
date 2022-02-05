#!/bin/sh
# Run every available test - Bash needed

THISDIR="$(realpath "$(dirname "$0")")"

# custom tools
PATH="$THISDIR"/tools:"$PATH"
export PATH

cd "$THISDIR/test"
for test in *test;
do
	echo "Running test $test ..."
	bash "$test" || { echo "*** ERROR: Test '$test' failed!"; exit 1; }
done
