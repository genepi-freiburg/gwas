#!/bin/bash


ADJS="adjusted unadjusted"

if [ "${SKIP_UNADJUSTED}" == "1" ]
then
	ADJS="adjusted"
fi

mkdir -p ${DATA_DIR}/final

for PHENO in ${PHENOTYPE_NAMES}
do

for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do



	LOG_FILE=${LOG_DIR}/filter-sort-${PHENO}-${GROUP}-${ADJ}.log
	touch ${LOG_FILE}

        echo "Merge: ${PHENO} ${GROUP} ${ADJ}"
        ANNOVARFILE="${DATA_DIR}/annovar/${PHENO}/annovar-${GROUP}-${ADJ}.in.refGene.variant_function"
        #POSFILE="${DATA_DIR}/filtered-with-pos/${PHENO}/gwama-${GROUP}-${ADJ}.out"
        OUTFILE="${DATA_DIR}/final/${PHENO}-${GROUP}-${ADJ}.txt"
	Rscript ${SCRIPT_DIR}/06-filter-sort.R "${ANNOVARFILE}" "${OUTFILE}" | tee ${LOG_FILE}

done
done
done
