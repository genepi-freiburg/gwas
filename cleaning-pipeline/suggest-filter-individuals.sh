#!/bin/bash
DIR=${0%/*}
. ${DIR}/parameters.sh

echo -n "PC1_MIN "
read PC1_MIN

echo -n "PC1_MAX "
read PC1_MAX

echo -n "PC2_MIN "
read PC2_MIN

echo -n "PC2_MAX "
read PC2_MAX

log "run IBD qc"
CWD=`pwd`
cd ${RESULT_DIR}
${SCRIPT_DIR}/aux/run-IBD-QC.pl ${SOURCE_NAME} | tee -a ${MAIN_LOG_FILE}
cd ${CWD}

log "assemble results table; using PC cutoffs ${PC1_MIN}-${PC1_MAX}; ${PC2_MIN}-${PC2_MAX}"
Rscript ${SCRIPT_DIR}/filter/make-result-table.R ${RESULT_DIR} ${SOURCE_NAME} ${PC1_MIN} ${PC1_MAX} ${PC2_MIN} ${PC2_MAX}
