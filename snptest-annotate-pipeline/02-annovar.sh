ADJS="adjusted unadjusted"

for PHENO in ${PHENOTYPE_NAMES}
do

for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do

        echo "Annotate: ${PHENO} ${GROUP} ${ADJ}"

        OUT_DIR=${DATA_DIR}/annovar/${PHENO}
        mkdir -p ${OUT_DIR}
        ANNFILE=${OUT_DIR}/annovar-${GROUP}-${ADJ}.in

        POSFILE="${DATA_DIR}/filtered-with-pos/${PHENO}/gwama-${GROUP}-${ADJ}.out"
	cat ${POSFILE} | tail -n+2 > ${ANNFILE}

	PROTOCOLS=refGene
	OPERATION=g

	${ANNOVAR}/table_annovar.pl ${ANNFILE} ${ANNOVAR}/humandb/ \
	        -buildver hg19 \
	        -protocol ${PROTOCOLS} \
	        -operation ${OPERATION} &

done
done

echo "Waiting for ${PHENO} to finish"
wait

done

echo Waiting for last jobs
wait
