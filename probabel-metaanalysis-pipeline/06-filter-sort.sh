#!/bin/bash

mkdir -p ${DATA_DIR}/final

for GROUP in ${METAANALYSIS_GROUPS}
do
	LOG_FILE=${LOG_DIR}/filter-sort-${GROUP}.log
	touch ${LOG_FILE}

        echo "Merge: ${GROUP}"
        ANNOVARFILE="${DATA_DIR}/annovar/annovar-${GROUP}.in.refGene.variant_function"
        OUTFILE="${DATA_DIR}/final/results-${GROUP}.txt"
	echo "Annover: ${ANNOVARFILE}"
	Rscript ${SCRIPT_DIR}/06-filter-sort.R "${ANNOVARFILE}" "${OUTFILE}" | tee ${LOG_FILE}

done
