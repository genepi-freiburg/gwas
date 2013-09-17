#!/bin/bash
FNS="whites_4c whites_escape turks_4c turks_escape whites_ckid"
PTH=$1
CHR=$2
RSID=$3
echo "Path: $PTH, Chromosome: $CHR, rsid: $RSID"
cat ${PTH}/whites_4c-chr${CHR}.out | grep ${RSID} | cut -f 2-6 -d " "
for FN in ${FNS}
do
	COUNTS=`cat ${PTH}/${FN}-chr${CHR}.out | grep ${RSID} | cut -f 2,10-12 -d " "`
	echo "${FN}: ${COUNTS}"
done


