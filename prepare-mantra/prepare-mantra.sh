#!/bin/bash

if [ ! -f "${1}" ]
then
	echo "Usage: ${0} param-file"
	exit 9
fi

SCRIPT_DIR=${0%/*}

# read params
. ${1}

mkdir -p ${DATA_DIR}
LOG_FILE=${DATA_DIR}/log.txt
rm -f $LOG_FILE
touch -f $LOG_FILE

# Formatting
. ${SCRIPT_DIR}/collect-snps.sh

# Collect GWAS results
perl ${SCRIPT_DIR}/create-gwas-db.pl ${DATA_DIR} ${FILES}

# Build Mantra Data file
perl ${SCRIPT_DIR}/build-mantra-dat.pl ${DATA_DIR}/mantra.in ${DATA_DIR}/mantra.dat \
	${DATA_DIR}/all-snps-uniq.txt ${DATA_DIR}/gwas.sqlite ${MIN_STUDIES}

