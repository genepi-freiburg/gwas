#!/bin/bash

ADJS="adjusted unadjusted"

mkdir -p ${DATA_DIR}/final

for PHENO in ${PHENOTYPE_NAMES}
do

for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do

        echo "Merge: ${PHENO} ${GROUP} ${ADJ}"

        ANNOVARFILE="${DATA_DIR}/annovar/${PHENO}/annovar-${GROUP}-${ADJ}.in.hg19_multianno.txt"
        POSFILE="${DATA_DIR}/filtered-with-pos/${PHENO}/gwama-${GROUP}-${ADJ}.out"
        OUTFILE="${DATA_DIR}/final/${PHENO}-${GROUP}-${ADJ}.csv"
	Rscript ${SCRIPT_DIR}/06-merge.R "${POSFILE}" "${ANNOVARFILE}" "${OUTFILE}"

done
done
done
