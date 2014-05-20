for GROUP in ${METAANALYSIS_GROUPS}
do


        echo "Annotate: ${GROUP}"

        OUT_DIR=${DATA_DIR}/annovar
        mkdir -p ${OUT_DIR}
        ANNFILE=${OUT_DIR}/annovar-${GROUP}.in

        POSFILE="${DATA_DIR}/filtered/gwama-${GROUP}.out"
	cat ${POSFILE} | tail -n+2 > ${ANNFILE}

	PROTOCOLS=refGene
	OPERATION=g

	${ANNOVAR}/table_annovar.pl ${ANNFILE} ${ANNOVAR}/humandb/ \
	        -buildver hg19 \
	        -protocol ${PROTOCOLS} \
	        -operation ${OPERATION} 



done

echo Waiting for last jobs
wait
