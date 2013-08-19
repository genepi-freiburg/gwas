#!/bin/bash

log "Analyze raw data file"
${PLINK} --noweb \
        --bfile ${SOURCE_FILE} \
        --out ${TEMP_DIR}/00-nofounders \
		2>&1 >/dev/null

mv ${TEMP_DIR}/00-nofounders.log ${LOG_DIR}/rawdata.log
rm -f ${TEMP_DIR}/00-nofounders.hh

if [ -f ${TEMP_DIR}/00-nofounders.nof ]
then

log "Recode to exclude non-founder SNPs"
${PLINK} --noweb \
        --bfile ${SOURCE_FILE} \
        --make-bed \
        --recode \
        --exclude ${TEMP_DIR}/00-nofounders.nof \
        --out ${SOURCE_NOF_FILE} \
		2>&1 >/dev/null

mv ${SOURCE_NOF_FILE}.log ${LOG_DIR}/nofounders.log

else
	ln -s ${SOURCE_FILE}.bed ${SOURCE_NOF_FILE}.bed
	ln -s ${SOURCE_FILE}.bim ${SOURCE_NOF_FILE}.bim
	ln -s ${SOURCE_FILE}.fam ${SOURCE_NOF_FILE}.fam
fi

rm -f ${SOURCE_NOF_FILE}.hh
rm -f ${TEMP_DIR}/00-nofounders.nof

# total indiv count(m/f) at start
echo "INDIVIDUAL STATISTICS" >> ${SUMMARY_FILE}
egrep "^[0-9]+ cases, .* controls and .* missing" ${LOG_DIR}/rawdata.log >> ${SUMMARY_FILE}
egrep "^[0-9]+ males, .* females, and .* of unspecified sex" ${LOG_DIR}/rawdata.log >> ${SUMMARY_FILE}
echo >> ${SUMMARY_FILE}

echo "SNP STATISTICS (RAW DATA)" >> ${SUMMARY_FILE}
grep ".* markers to be included from" ${LOG_DIR}/rawdata.log >> ${SUMMARY_FILE}
grep ".* SNPs with no founder genotypes observed" ${LOG_DIR}/rawdata.log >> ${SUMMARY_FILE}
echo >> ${SUMMARY_FILE}

if [ -f "${LOG_DIR}/nofounders.log" ]
then
	echo "SNP STATISTICS (AFTER NOF PRUNING)" >> ${SUMMARY_FILE}
	egrep "After frequency and genotyping pruning, there are [0-9]+ SNPs" ${LOG_DIR}/nofounders.log >> ${SUMMARY_FILE}
	echo >> ${SUMMARY_FILE}
else
	echo "Data contains only founder genotypes." >> ${SUMMARY_FILE}
fi

