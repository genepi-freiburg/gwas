#!/bin/bash

if [ ! -f "${1}" ]
then
	echo "Usage: ${0} param-file"
	exit 9
fi

SCRIPT_DIR=${0%/*}

# read params
. ${1}

if [ "${EXPERIMENT}" != "" ]
then
	if [ ! -d "${EXPERIMENT}" ]
	then
		echo "Experiment directory does not exist: ${EXPERIMENT}"
		exit
	fi
fi

LOG_DIR=${DATA_DIR}/log
mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

# prepare sample file
. ${SCRIPT_DIR}/01-prepare-sample.sh

# check return code
if [ "$RC" != 0 ]
then
	echo "Sample file formatting failed - check logs"
	exit
fi

echo "Proceed?"
read

# SNPtest
. ${SCRIPT_DIR}/02-snptest.sh

# Formatting
. ${SCRIPT_DIR}/03-formatting.sh

# gwasqc
. ${SCRIPT_DIR}/04-run-gwasqc.sh
