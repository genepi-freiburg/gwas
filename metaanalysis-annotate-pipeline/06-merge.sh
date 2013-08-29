#!/bin/bash

cd filtered-with-pos
FNS=`ls -1 *.out`
cd ..

for FN in ${FNS}
do
echo $FN
Rscript 06-merge.R ${FN}

done
