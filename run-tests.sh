#!/bin/sh
# Run every available test
cd test
for test in *test;
do
	if ! ./$test; then
		echo
		echo "*** ERROR: Test '$?' failed!"
		echo
		exit 1
	fi
done