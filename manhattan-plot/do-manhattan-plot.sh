#!/bin/bash
if [ $# != 8 ]
then
	echo "Usage: $0 <input-file> <maf-filter> <snp-col> <chr-col> <pos-col> <pval-col> <maf-col> <output-file>"
	exit 9
fi

IN_FILE=$1
if [ ! -f "${IN_FILE}" ]
then
	echo "Input file $IN_FILE does not exist"
	exit 9
fi

MAF_FILTER=$2
if [[ ( "${MAF_FILTER}" < 0.01 ) || ( "${MAF_FILTER}" > 0.99 ) ]]
then
	echo "MAF filter $MAF_FILTER must be between 0 and 1"
	exit 9
fi

SNP_COL=$3
CHR_COL=$4
BP_COL=$5
PVAL_COL=$6
MAF_COL=$7
OUT_FILE=$8
SCRIPT_DIR=${0%/*}

echo "Using column names: "
echo " - RSID column: '$SNP_COL'"
echo " - chromosome column: '$CHR_COL'"
echo " - position column: '$BP_COL'"
echo " - p value column: '$PVAL_COL'"
echo " - MAF column: '$MAF_COL'"
echo
echo "Writing output to: $OUT_FILE"
echo "Script path: $SCRIPT_DIR"

xvfb-run Rscript ${SCRIPT_DIR}/plot.R $IN_FILE $SCRIPT_DIR $MAF_FILTER $SNP_COL $CHR_COL $BP_COL $PVAL_COL $MAF_COL $OUT_FILE

echo "Finished"
