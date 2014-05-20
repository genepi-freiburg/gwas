for GROUP in ${METAANALYSIS_GROUPS}
do

	echo "Filter ${GROUP}"
	INFN="${DATA_DIR}/output/gwama-${GROUP}.out"
	OUT_DIR="${DATA_DIR}/filtered/${PHENO}"
	OUT_FN="${OUT_DIR}/gwama-${GROUP}.out"
	mkdir -p ${OUT_DIR}
	head -n 1 ${INFN} > ${OUT_FN}
	cat ${INFN} | perl ${SCRIPT_DIR}/filter.pl >> ${OUT_FN} 

	cat ${OUT_FN} | \
		awk '{ if (NR>1) { 
			print $1,$2,$2-1+length($5),$4,$5,$3,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19 
		} else { 
			print $1,"start","stop",$4,$5,$3,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19 
		} }' > ${OUT_FN}.2
	mv ${OUT_FN}.2 ${OUT_FN}

done

echo Waiting for last jobs
wait

