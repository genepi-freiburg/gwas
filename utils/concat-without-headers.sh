#!/bin/bash

ARGCOUNT=$#
if [ $ARGCOUNT -lt 3 ]
then
	echo "Usage: $0 <file1> <file2> ... <outfile>"
	exit 3
fi

CONCAT_COUNT=$((ARGCOUNT - 1))

OUTFN=${@: -1}
echo "Write output to: $OUTFN"
echo "Total file count: $CONCAT_COUNT"
echo "Extract header from: $1"

head -n 1 $1 > $OUTFN

for IDX in `seq 1 $CONCAT_COUNT`
do
	VARNAME="\${${IDX}}"
	FN=`eval "echo $VARNAME"`
	echo "Concat ${FN} (${IDX}/${CONCAT_COUNT})"
	tail -n +2 $FN >> $OUTFN
done

wc -l $@

echo "Done"
