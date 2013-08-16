#!/bin/bash

${PLINK} --noweb \
        --bfile ${SOURCE_NOF_FILE} \
        --het \
        --out ${TEMP_DIR}/03-heterozygosity \
		2>&1 >/dev/null

mv ${TEMP_DIR}/03-heterozygosity.log ${LOG_DIR}/heterozygosity.log
mv ${TEMP_DIR}/03-heterozygosity.het ${RESULT_DIR}/${SOURCE_NAME}.het
rm -f ${TEMP_DIR}/03-heterozygosity.hh

Rscript ${SCRIPT_DIR}/03-analyze-heterozygosity.R ${RESULT_DIR}/${SOURCE_NAME} ${TEMP_DIR}/03-heterozygosity-analysis.txt 2>&1 >/dev/null

echo "HETEROZYGOSITY ANALYSIS" >> ${SUMMARY_FILE}
cat ${TEMP_DIR}/03-heterozygosity-analysis.txt >> ${SUMMARY_FILE}
rm -f ${TEMP_DIR}/03-heterozygosity-analysis.txt
echo >> ${SUMMARY_FILE}


