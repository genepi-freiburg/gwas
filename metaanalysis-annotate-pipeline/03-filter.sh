ADJS="adjusted unadjusted"
if [ "${SKIP_UNADJUSTED}" == "1" ]
then
        ADJS="adjusted"
fi

for PHENO in ${PHENOTYPE_NAMES}
do


for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do

	echo "Filter ${PHENO} ${GROUP} ${ADJ}"
	INFN="${DATA_DIR}/output/${PHENO}/gwama-${GROUP}-${ADJ}.out"
	OUT_DIR="${DATA_DIR}/filtered/${PHENO}"
	OUT_FN="${OUT_DIR}/gwama-${GROUP}-${ADJ}.out"
	mkdir -p ${OUT_DIR}
	head -n 1 ${INFN} > ${OUT_FN}
	cat ${INFN} | perl ${SCRIPT_DIR}/filter.pl >> ${OUT_FN} &

	${SCRIPT_DIR}/wait-perl.sh

done
done
done

echo Waiting for last jobs
wait

