#!/bin/bash

### COMMANDLINE PARAMETERS
# directory where the raw data is stored
# BED/BIM/FAM or PED/MAP files must reside there
SOURCE_DIR=${1%/}

# check params
if [ -z "${SOURCE_DIR}" ]
then
	echo "Source dir required"
	exit
fi
echo "Using source dir ${SOURCE_DIR}"

# base name of study
SOURCE_NAME=$2

if [ -z "${SOURCE_NAME}" ]
then
	echo "Source name required"
	exit
fi

SOURCE_FILE="${SOURCE_DIR}/${SOURCE_NAME}"

if [ ! -f "${SOURCE_FILE}.bed" ]
then
	echo "Input BED not found: ${SOURCE_FILE}.bed"
	exit
fi

### GLOBAL PARAMETERS
IMISS_THRESH_DEFAULT=0.03
HET_SD_THRESH_DEFAULT=2
GENO_DEFAULT=0.97
MAF_DEFAULT=0.03
HWE_DEFAULT=1E-5

### GLOBAL VARIABLES
SCRIPT_DIR=~/gwas/cleaning-pipeline
LOG_DIR=${SOURCE_DIR}/logs
RESULT_DIR=${SOURCE_DIR}/results
TEMP_DIR=${SOURCE_DIR}/temp

MAIN_LOG_FILE=${LOG_DIR}/main.log
SOURCE_NOF_FILE=${SOURCE_FILE}_nof
SUMMARY_FILE=${RESULT_DIR}/summary.txt

PLINK=/usr/lib/plink/plink
CONVERTF=/opt/eigenstrat/bin/convertf
SMARTPCA=/opt/eigenstrat/bin/smartpca

# logger
log() {
	DATE=`date`
	MESSAGE="${DATE} $1"
	echo ${MESSAGE} >>${MAIN_LOG_FILE}
	echo ${MESSAGE}
}

