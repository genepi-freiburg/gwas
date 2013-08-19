#!/bin/bash

${PLINK} --noweb \
        --check-sex \
        --bfile ${SOURCE_NOF_FILE} \
        --out ${TEMP_DIR}/01-sexcheck \
		2>&1 >/dev/null

mv ${TEMP_DIR}/01-sexcheck.log ${LOG_DIR}/sexcheck.log
rm -f ${TEMP_DIR}/01-sexcheck.hh

cat ${TEMP_DIR}/01-sexcheck.sexcheck | head -n 1 > ${RESULT_DIR}/sexcheck.txt
cat ${TEMP_DIR}/01-sexcheck.sexcheck | grep PROBLEM >> ${RESULT_DIR}/sexcheck.txt


cat ${RESULT_DIR}/sexcheck.txt | \
	tail -n+2 | \
	awk '{ if ($3 != "0" && $4 != "0") print $2}' \
	> ${RESULT_DIR}/fail-sexcheck.txt

SEX_COUNT=`wc -l ${RESULT_DIR}/fail-sexcheck.txt | awk '{ print $1}'`
rm ${TEMP_DIR}/01-sexcheck.sexcheck
log "individuals failing sex check: ${SEX_COUNT}"

echo "SEX CHECK" >> ${SUMMARY_FILE}
echo "individuals failing sex check: ${SEX_COUNT}" >> ${SUMMARY_FILE}
echo >> ${SUMMARY_FILE}
