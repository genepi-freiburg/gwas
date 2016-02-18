#!/bin/bash

IN_GEN=$1
IN_SAMPLE=$2
IN_KEEP=$3 
OUT_FREQ=$4

QCTOOL=/data/gwas/bin/qctool/qctool_v1.3-linux-x86_64/qctool
GTOOL=/opt/gtool/gtool

TEMP_DIR=/scratch/local/mw_freq_temp
mkdir -p ${TEMP_DIR}

BASENAME_GEN=`basename ${IN_GEN}`
BASENAME_SAMPLE=`basename ${IN_SAMPLE}`

TEMP_GEN=${TEMP_DIR}/${BASENAME_GEN}
TEMP_SAMPLE=${TEMP_DIR}/${BASENAME_SAMPLE}

echo "Run gtool, convert $IN_GEN -> $TEMP_GEN, $IN_SAMPLE -> $TEMP_SAMPLE"
${GTOOL} -S \
	--g ${IN_GEN} \
	--s ${IN_SAMPLE} \
	--og ${TEMP_GEN} \
	--os ${TEMP_SAMPLE} \
	--sample_id ${IN_KEEP}

# missing column case hack

if [[ $IN_GEN == *".gz"* ]]
then
	echo "gz data found, uncompress sample file ${TEMP_SAMPLE}.gz -> ${TEMP_SAMPLE}"
	gunzip -f ${TEMP_SAMPLE}.gz
	ls -l ${TEMP_SAMPLE}
fi

echo "Replace MISSING with missing in ${TEMP_SAMPLE}"
cat ${TEMP_SAMPLE} | sed s/MISSING/missing/ > ${TEMP_SAMPLE}.2
mv ${TEMP_SAMPLE}.2 ${TEMP_SAMPLE}

echo Run QC tool
${QCTOOL} \
	-g ${TEMP_GEN} \
	-s ${TEMP_SAMPLE} \
	-snp-stats ${OUT_FREQ}

