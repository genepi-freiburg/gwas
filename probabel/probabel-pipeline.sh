#!/bin/bash

if [ ! -f "${1}" ]
then
        echo "Usage: ${0} param-file"
        exit 9
fi

SCRIPT_DIR=${0%/*}

# read params
. ${1}

LOG_DIR=${DATA_DIR}/log
mkdir -p ${LOG_DIR}

. ${SCRIPT_DIR}/01-convert-phenotype.sh

echo "Phenotype Conversion DONE - check logs - OK to start?"
read

. ${SCRIPT_DIR}/02-calculate-snp-freqs.sh
. ${SCRIPT_DIR}/03-run-probabel.sh 
. ${SCRIPT_DIR}/04-formatting.sh
. ${SCRIPT_DIR}/05-run-gwasqc.sh
