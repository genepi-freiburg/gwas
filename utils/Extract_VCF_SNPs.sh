#!/bin/bash
# Extract SNPs from Gen files and convert to Raw dosage format
#
# Input:
# 1) file with "rsid"
# 2) path to VCF files (pattern)
# 3) output file name
#
# Processing:
# 1) Lookup chr for rsids
# 2) Extract SNPs from Gen files
# 3) Merge extracted SNPs
# 4) Format extracted SNPs (transpose, calculate dosage, determine allele codes)
#
# Output:
# 1) file with individuals in rows and SNPs in columns with dosages

#############################################
### PROCESS ARGUMENTS
#############################################

SNP_FILE=$1
VCF_PATH=$2
OUT_FILE=$3

NOT_FOUND_FN="${OUT_FILE}.not_found"

if [ "$#" -lt "3" ]
then
	echo "Usage: Extract_VCF_SNPs.sh <snp_file> <vcf_path> <out_file>"
	echo "Example: ./Extract_VCF_SNPs.sh snps.txt chr-%CHR%.dose.vcf.gz snps_out.raw"
	echo "vcf_path should have %CHR% placeholder; there must be corresponding .tbi files"
	echo "snp_file should have variants with names like '7:12345'."
	exit 8
fi

if [ ! -f "$SNP_FILE" ]
then
	echo "Input file '$SNP_FILE' does not exist!"
	exit 9
else
	echo "Using SNP input file: $SNP_FILE"
fi

if [ -f "$OUT_FILE" ]
then
	echo "Output file '$OUT_FILE' already exists - please remove the file."
	exit 9
else
	echo "Write output to: $OUT_FILE"
fi

TMP_DIR="tmp"
mkdir -p $TMP_DIR

#############################################
### EXTRACT SNPS
#############################################

cat $SNP_FILE | while read SNP
do
	echo -n "Got line: '${SNP}' => "
	CHR=$(echo "$SNP" | cut -f 1 -d ':')
	POS=$(echo "$SNP" | cut -f 2 -d ':')
	if [ "$CHR" = "" ] || [ "$POS" = "" ]
	then
		echo "Invalid line in input file - expect nn:nnnn"
		exit 9
	fi
	echo "Found chromosome ${CHR} and position ${POS}."

	VCF_FILE=`echo "${VCF_PATH}" | sed s/%CHR%/${CHR}/g`
	if [ ! -f "${SNP_FILE}" ]
	then
		echo "VCF file not found: ${VCF_FILE}"
		exit 9
	fi
	echo "Using VCF file: ${VCF_FILE}"

	POS1=$((POS + 1))
	TABIX_PATTERN="${CHR}:${POS}-${POS1}"
	TABIX_OUT="$TMP_DIR/extract-chr${CHR}-${POS}.vcfline"
	echo "Tabix pattern: ${TABIX_PATTERN}; out file: ${TABIX_OUT}"
	tabix $VCF_FILE ${TABIX_PATTERN} > ${TABIX_OUT}
	if [ ! -s ${TABIX_OUT} ]
	then
		echo "WARNING: Empty result - SNP not found!"
	fi
done

VCF_FILE=`echo "${VCF_PATH}" | sed s/%CHR%/22/g`
echo "Find header from: ${VCF_FILE}"
zcat ${VCF_FILE} | head -n 100 | grep -v '^##' | grep '^#' > ${TMP_DIR}/vcf-header-line.vcfline

echo "Merge extracted SNPs"
cat $TMP_DIR/vcf-header-line.vcfline $TMP_DIR/extract-*.vcfline > $TMP_DIR/all-extracted.vcf

echo "SNP count:"
wc -l $TMP_DIR/all-extracted.vcf

echo "Convert merged file"
#Rscript Convert_Gen_to_Raw.R $TMP_DIR/all-extracted.gen $FAM_FILE $OUT_FILE
#rm -f $TMP_DIR/all-extracted.gen

echo "Finished"
