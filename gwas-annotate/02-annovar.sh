ADJS="adjusted unadjusted"

if [ "${SKIP_UNADJUSTED}" == 1 ]
then
        ADJS="adjusted"
fi
        
OUT_DIR=${DATA_DIR}/annovar
mkdir -p ${OUT_DIR}

for PHENO in ${PHENOTYPE_NAMES}
do

for COHORT in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

        echo "Annotate: ${PHENO} ${COHORT} ${ADJ}"

        ANNFILE=${OUT_DIR}/annovar-${COHORT}-${PHENO}-${ADJ}.in

        POSFILE="${DATA_DIR}/filtered-${COHORT}-${PHENO}-${ADJ}.gwas"
	Rscript ${SCRIPT_DIR}/02-prepare-annovar.R ${POSFILE} ${ANNFILE}

	PROTOCOLS=refGene
	OPERATION=g

	${ANNOVAR}/table_annovar.pl ${ANNFILE} ${ANNOVAR}/humandb/ \
	        -buildver hg19 \
	        -protocol ${PROTOCOLS} \
	        -operation ${OPERATION} 

	# mehr Formatierung (Spaltenkoepfe! Tab vs. Whitespace)
	Rscript ${SCRIPT_DIR}/02-postprocess-annovar.R ${ANNFILE}.refGene.variant_function ${DATA_DIR}/annovar-${COHORT}-${PHENO}-${ADJ}.out.txt
done
done

echo "Waiting for ${PHENO} to finish"
wait

done

echo Waiting for last jobs
wait
