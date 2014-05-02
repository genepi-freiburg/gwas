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

TEMP_GEN=${TEMP_DIR}/${BASENAME_GEN}.subset
TEMP_SAMPLE=${TEMP_DIR}/${BASENAME_SAMPLE}.subset

echo Run gtool
${GTOOL} -S \
	--g ${IN_GEN} \
	--s ${IN_SAMPLE} \
	--og ${TEMP_GEN} \
	--os ${TEMP_SAMPLE} \
	--sample_id ${IN_KEEP}

# missing column case hack
cat ${TEMP_SAMPLE} | sed s/MISSING/missing/ > ${TEMP_SAMPLE}.2
cp ${TEMP_SAMPLE}.2 ${TEMP_SAMPLE}

echo Run QC tool
${QCTOOL} \
	-g ${TEMP_GEN} \
	-s ${TEMP_SAMPLE} \
	-snp-stats ${OUT_FREQ}

