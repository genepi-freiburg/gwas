#!/bin/bash

SCRIPT_DIR=${0%/*}
. ${SCRIPT_DIR}/parameters.sh

### INIT
# init directories
mkdir -p ${LOG_DIR}
mkdir -p ${RESULT_DIR}
mkdir -p ${TEMP_DIR}

rm -f ${MAIN_LOG_FILE}
touch ${MAIN_LOG_FILE}

rm -f ${SUMMARY_FILE}
echo "Data Cleaning Summary" > ${SUMMARY_FILE}
date >> ${SUMMARY_FILE}
echo >> ${SUMMARY_FILE}

### PIPELINE
log "filter non-founder SNPs"
. ${SCRIPT_DIR}/cleaning/00-no-founders.sh

log "perform sex check"
. ${SCRIPT_DIR}/cleaning/01-sexcheck.sh

log "perform missingness analysis"
. ${SCRIPT_DIR}/cleaning/02-missingness.sh

log "perform heterozygosity analysis"
. ${SCRIPT_DIR}/cleaning/03-heterozygosity.sh

log "plot heterozygosity and missingness"
. ${SCRIPT_DIR}/cleaning/04-plot-het-miss.sh

log "perform cryptic relatedness analysis"
. ${SCRIPT_DIR}/cleaning/05-relatedness.sh

log "perform PCA"
. ${SCRIPT_DIR}/cleaning/06-pca.sh

log "cleaning finished"
