# Input:   SOURCE_FILE - relative path to BED/BIM/FAM  e.g. ../../CKID_Cleaned/whites_ckid/whites_ckid
#          OUTPUT_DIR  - file to place results, intermediates and logs
#          PREFIX      - file name prefix              e.g. whites_ckid
#	   PC_COUNT    - number of PC's to calculate, default 10
#	   MAF_FILTER  - MAF filter to apply, default 0 = none, give as decimal, e.g. 0.05
# Output:  ${PREFIX}.evec and ${PREFIX}.pdf files

SOURCE_FILE=$1
OUTPUT_DIR=$2
PREFIX=$3
PC_COUNT=$4
MAF_FILTER=$5

if [ "${PC_COUNT}" == "" ]
then
	PC_COUNT=10
fi

if [ "${MAF_FILTER}" == "" ]
then
	MAF_FILTER=0
fi

SCRIPT_DIR=${0%/*}

if [ ! -f "${SOURCE_FILE}.bed" ]
then
	echo "BED does not exist: ${SOURCE_FILE}.bed"
	exit
fi

echo "Input: ${SOURCE_FILE}"
echo "Output to: ${OUTPUT_DIR}"
echo "Prefix: ${PREFIX}"
echo "PC count: ${PC_COUNT}"
mkdir -p ${OUTPUT_DIR}

. ${SCRIPT_DIR}/01-exclude-high-LD-snps.sh 
. ${SCRIPT_DIR}/02-save-ped.sh 
. ${SCRIPT_DIR}/03-convertf.sh 
. ${SCRIPT_DIR}/04-smartpca.sh

export OUTPUT_DIR
export PREFIX
Rscript ${SCRIPT_DIR}/05-plot-pca-results.R
