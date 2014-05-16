GWAS_DIR=$1
GWAMA_OUT_FILE=$2

GWAMA=/data/gwas/bin/gwama/GWAMA

GWAMA_IN_FILE=/tmp/gwama.in
ls ${GWAS_DIR}/*.gwas >${GWAMA_IN_FILE}

MAP_FILE=/data/gwas/pediGFR_gwas/Metaanalysis/Imputed/map/ALL_1000G.map

# TODO convert GWAS files and filter for MAF before gwama (because of lambda correction)

${GWAMA} -qt -gc -gco \
	-i ${GWAMA_IN_FILE} \
	-o ${GWAMA_OUT_FILE} \
	--indel_alleles \
	--map ${MAP_FILE} \
	 2>&1 > ${GWAMA_OUT_FILE}.log

