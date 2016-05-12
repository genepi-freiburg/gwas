#!/bin/bash
# Extract SNPs from Gen files and convert to Raw dosage format
#
# Input:
# 1) file with "rsid"
# 2) path to GEN files
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
GEN_PATH=$2
OUT_FILE=$3
GEN_PATTERN=$4
GEN_PATTERN_DEFAULT="GCKD_Common_Clean-chr%CHR%.gen.gz"

NOT_FOUND_FN="${OUT_FILE}.not_found"
FAM_FILE="GCKD_Common_Clean.fam"
LEGEND_DB="/data/gwas/1kgp_phase3/1000GP_Phase3/Legend_DB/ALL_1000G_Phase3_Legend.sqlite"

if [ "$#" -lt "3" ]
then
	echo "Usage: ExtractSNPs.sh <snp_file> <gen_path> <out_file> [<gen_pattern>]"
	echo "Example: ./ExtractSNPs.sh snps.txt 01_Common_Genotyped_Call96_HWE5/gen snps_out.raw"
	echo "'gen_pattern' is optional and defaults to '$GEN_PATTERN_DEFAULT'."
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

if [ ! -d "$GEN_PATH" ]
then
	echo "Directory '$GEN_PATH' with .gen.gz files does not exist - check path."
	exit 9
else
	echo "Load GEN files from: $GEN_PATH"
fi

if [ "$GEN_PATTERN" == "" ]
then
	GEN_PATTERN="$GEN_PATTERN_DEFAULT"
fi
echo "Using GEN filename pattern: $GEN_PATTERN"


#############################################
### EXTRACT SNPS
#############################################

cat $SNP_FILE | while read SNP
do
	# if line contains both SNP and chromosome number (separated by whitespace),
	# use this chromosome number
	echo "Got line: '${SNP}'"
	ACTUAL_SNP=$(echo "$SNP" | cut -f 1)
	CHR=$(echo "$SNP" | cut -f 2)
	if [ "$CHR" == "" ]
	then
		echo -n "Quering for chromosome number of SNP '$SNP': "
		QUERY="select chr from snps where rsid = '${SNP}';"
		CHR=`echo $QUERY | sqlite3 $LEGEND_DB`
	else
		SNP=${ACTUAL_SNP}
		echo -n "Found chromosome in SNP file, SNP = ${SNP}: "
	fi
	echo "Got ${CHR}."

	# build GEN path for chromosome	
	GEN=$GEN_PATH
	HAVE_SLASH_END=`echo "${GEN}" | grep "\/$"`
	if [ "$HAVE_SLASH_END" == "" ]
	then
		GEN="${GEN}/"
	fi
	GEN=`echo ${GEN}${GEN_PATTERN} | sed s/%CHR%/${CHR}/g`

	echo "Extracting SNP '$SNP' from GEN file '$GEN'"
	zcat $GEN 2>/dev/null | grep "${SNP} " > /tmp/extract-$SNP.gen 

	if [ ! -s /tmp/extract-$SNP.gen ]
	then
		
		echo "WARNING: SNP $SNP not found; this is logged to '${NOT_FOUND_FN}'."
		echo $SNP >> ${NOT_FOUND_FN}
	fi
done

echo "Merge extracted SNPs"
cat /tmp/extract-*.gen > /tmp/all-extracted.gen
rm -f /tmp/extract-*.gen

echo "Convert merged file"
Rscript Convert_Gen_to_Raw.R /tmp/all-extracted.gen $FAM_FILE $OUT_FILE
#rm -f /tmp/all-extracted.gen

echo "Finished"
