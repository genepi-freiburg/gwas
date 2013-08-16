#!/bin/bash

${PLINK} --noweb \
        --bfile ${SOURCE_NOF_FILE} \
        --missing \
        --out ${TEMP_DIR}/02-missingness \
		2>&1 >/dev/null

log "filtering missingness results"
mv ${TEMP_DIR}/02-missingness.log ${LOG_DIR}/missingness.log
mv ${TEMP_DIR}/02-missingness.imiss ${RESULT_DIR}/${SOURCE_NAME}.imiss
mv ${TEMP_DIR}/02-missingness.lmiss ${RESULT_DIR}/${SOURCE_NAME}.lmiss
rm -f ${TEMP_DIR}/02-missingness.hh

cat ${RESULT_DIR}/${SOURCE_NAME}.imiss | tail -n +2 | \
	awk '$6 > 0.03 {print $2;}' > ${RESULT_DIR}/fail-missingness.txt

MISS_FAIL_COUNT=`wc -l ${RESULT_DIR}/fail-missingness.txt | awk '{ print $1}'`
log "individuals failing missingness test: ${MISS_FAIL_COUNT}"

echo "MISSINGNESS" >> ${SUMMARY_FILE}
echo "individuals failing (preliminary) missingness test: ${MISS_FAIL_COUNT}; missingness cut-off 0.03" >> ${SUMMARY_FILE}
echo >> ${SUMMARY_FILE}


