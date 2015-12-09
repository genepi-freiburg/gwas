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
FAM_FILE=$3
OUT_FILE=$4
GEN_PATTERN=$5

NOT_FOUND_FN="${OUT_FILE}.not_found"
LEGEND_DB="/data/gwas/pediGFR_gwas/Metaanalysis/Imputed/map/ALL_1000G.sqlite"

if [ "$#" -lt "5" ]
then
	echo "Usage: ExtractSNPs.sh <snp_file> <gen_path> <fam_file> <out_file> <gen_pattern>"
	echo "Example: ./ExtractSNPs.sh snps.txt 01_Common_Genotyped_Call96_HWE5/gen whites_4c.fam snps_out.raw whites_4c-chr%CHR%.gen"
	exit 8
fi

if [ ! -f "$SNP_FILE" ]
then
	echo "Input file '$SNP_FILE' does not exist!"
	exit 9
else
	echo "Using SNP input file: $SNP_FILE"
fi

if [ ! -f "$FAM_FILE" ]
then
        echo "FAM file '$FAM_FILE' does not exist - please check the path and the file name."
        exit 9
else
        echo "Use FAM file: $FAM_FILE"
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
	echo "GEN pattern missing - please give GEN pattern."
	exit 9
fi
echo "Using GEN filename pattern: $GEN_PATTERN"


#############################################
### EXTRACT SNPS
#############################################

SNPS=`cat $SNP_FILE`
for SNP in $SNPS
do
	echo -n "Quering for chromosome number of SNP '$SNP': "
	QUERY="select chr from snps where rsid = '${SNP}';"
	CHR=`echo $QUERY | sqlite3 $LEGEND_DB`
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
	cat $GEN 2>/dev/null | grep "${SNP} " > /tmp/extract-$SNP.gen 

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
Rscript ~/gwas/utils/Convert_Gen_to_Raw.R /tmp/all-extracted.gen $FAM_FILE $OUT_FILE
#rm -f /tmp/all-extracted.gen

echo "Finished"
