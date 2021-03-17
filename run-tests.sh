#!/bin/sh
# Run every available test
cd test
for test in *test;
do
	./$test || { echo "*** ERROR: Test '$test' failed!"; exit 1; }
done