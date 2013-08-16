#!/bin/bash

log "excluding SNPs in high-LD regions; prune SNPs"

${PLINK} --noweb \
       --bfile ${SOURCE_NOF_FILE} \
	--exclude ${SCRIPT_DIR}/aux/high-LD-regions.txt \
	--range --indep-pairwise 50 5 0.2 \
	--out ${TEMP_DIR}/01-high-ld \
		2>&1 >/dev/null

mv ${TEMP_DIR}/01-high-ld.log ${LOG_DIR}/high-ld.log

log "calculate pairwise IBS"

${PLINK} --noweb \
       --bfile ${SOURCE_NOF_FILE} \
	--extract ${TEMP_DIR}/01-high-ld.prune.in \
	--genome \
	--out ${TEMP_DIR}/02-pairwise-IBS \
		2>&1 >/dev/null

rm -f ${TEMP_DIR}/01-high-ld.*
rm -f ${TEMP_DIR}/02-pairwise-IBS.hh
mv ${TEMP_DIR}/02-pairwise-IBS.genome ${RESULT_DIR}/${SOURCE_NAME}.genome
mv ${TEMP_DIR}/02-pairwise-IBS.log ${LOG_DIR}/pairwise-ibs.log

log "plot pairwise IBS"

Rscript ${SCRIPT_DIR}/05-plot-IBD.R ${RESULT_DIR}/${SOURCE_NAME} ${RESULT_DIR} ${SOURCE_DIR}/${SOURCE_NAME}.fam 2>&1 >/dev/null
