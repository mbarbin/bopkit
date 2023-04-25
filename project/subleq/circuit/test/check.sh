#!/bin/sh

prefix=$1
number=$2

echo "Check diff for subleq files with prefix='$prefix'"

for num in `seq 1 $number`; do
    if [ $num -lt 10 ]; then
		file=$prefix"-0"$num
    else
	    file=$prefix"-"$num
    fi
	echo diff $file.img $file.output
	diff $file.img $file.output
done
