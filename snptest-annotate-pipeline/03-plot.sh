ADJS="adjusted unadjusted"
if [ "${SKIP_UNADJUSTED}" == "1" ]
then
	ADJS="adjusted"
fi

for PHENO in ${PHENOTYPE_NAMES}
do

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

	if [ "$MANHATTAN_MAF_FILTER" == "" ]
	then
		MANHATTAN_MAF_FILTER=0.05
	fi

        echo "Plot ${PHENO} ${FN} ${ADJ}"
        INFN=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHENO}/g | sed s/%COHORT%/${FN}/g`
        OUT_FN="${DATA_DIR}/manhattan-${FN}-${PHENO}-${ADJ}.png"
	xvfb-run -a Rscript ${SCRIPT_DIR}/03-plot.R ${INFN} ${SCRIPT_DIR} ${OUT_FN} ${MANHATTAN_MAF_FILTER} | tee ${LOG_DIR}/manhattan-${FN}-${PHENO}-${ADJ}.log
	sleep 3
done

done
done
