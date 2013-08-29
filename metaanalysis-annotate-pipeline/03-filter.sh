ADJS="adjusted unadjusted"

for PHENO in ${PHENOTYPE_NAMES}
do


for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do

	echo "Filter ${PHENO} ${GROUP} ${ADJ}"
	INFN="${DATA_DIR}/output/${PHENO}/gwama-${GROUP}-${ADJ}.out"
	OUTDIR="${DATA_DIR}/filtered/${PHENO}"
	OUTFN="${OUT_DIR}/gwama-${GROUP}-${ADJ}.out"
	mkdir -p ${OUT_DIR}
	head -n 1 ${INFN} > ${OUTFN}
	cat ${INFN} | perl ${SCRIPT_DIR}/filter.pl >> ${OUTFN} &

	${SCRIPT_DIR}/wait-perl.sh

done
done
done

echo Waiting for last jobs
wait

