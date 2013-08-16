DIR=${0%/*}
. ${DIR}/parameters.sh
. ${DIR}/threshold-defaults.sh

#. ${USER_THRESHOLD_FILE}

echo "Using MAF ${MAF}"

if [ "${USE_IMISS_FILTER}" -eq "1"]
then
	echo "Using IMISS ${IMISS}"
fi

# individuals heterozygosity (SD from mean)
USE_HET_FILTER=1
HET=4

# IBD border
USE_IBD_FILTER=1
IBD=0.185

# PCA filter
USE_PC_FILTER=1
PC1_MIN=
PC1_MAX=
PC2_MIN=
PC2_MAX=

# SNP genotyping rate (callrate)
USE_GENO_FILTER=1
GENO=0.90

# SNP minor allele frequency
USE_MAF_FILTER=1
MAF=0.001

