#!/bin/bash


ADJS="adjusted unadjusted"

if [ "${SKIP_UNADJUSTED}" == "1" ]
then
	ADJS="adjusted"
fi

mkdir -p ${DATA_DIR}/final

IFS=' ' read -a PHENOTYPE_NAMES_ARR <<< "${PHENOTYPE_NAMES}"
IFS=' ' read -a PHENOTYPE_TYPES_ARR <<< "${PHENOTYPE_TYPES}"

PHENO_COUNT="${#PHENOTYPE_NAMES_ARR[@]}"

echo "Names: ${PHENOTYPE_NAMES}, Types: ${PHENOTYPE_TYPES}"
echo "Got ${PHENO_COUNT} phenotypes."

#for PHENO in ${PHENOTYPE_NAMES}
#do

for ((IDX=0; IDX < PHENO_COUNT; IDX++))
do

PHENO=${PHENOTYPE_NAMES_ARR[IDX]}
PHENOT=${PHENOTYPE_TYPES_ARR[IDX]}
echo "Processs ${PHENO} (type ${PHENOT})"

for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do

	LOG_FILE=${LOG_DIR}/filter-sort-${PHENO}-${GROUP}-${ADJ}.log
	touch ${LOG_FILE}

        echo "Merge: ${PHENO} ${GROUP} ${ADJ}"
        ANNOVARFILE="${DATA_DIR}/annovar/${PHENO}/annovar-${GROUP}-${ADJ}.in.refGene.variant_function"
        OUTFILE="${DATA_DIR}/final/${PHENO}-${GROUP}-${ADJ}.txt"
	echo "Annover: ${ANNOVARFILE}"
	Rscript ${SCRIPT_DIR}/06-filter-sort.R "${ANNOVARFILE}" "${OUTFILE}" "${PHENOT}" | tee ${LOG_FILE}

done
done
done
