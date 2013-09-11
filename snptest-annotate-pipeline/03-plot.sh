ADJS="adjusted unadjusted"

for PHENO in ${PHENOTYPE_NAMES}
do

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

        echo "Plot ${PHENO} ${FN} ${ADJ}"
        INFN=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHENO}/g | sed s/%COHORT%/${FN}/g`
        OUT_FN="${DATA_DIR}/manhattan-${FN}-${PHENO}-${ADJ}.png"
	xvfb-run Rscript ${SCRIPT_DIR}/03-plot.R ${INFN} ${SCRIPT_DIR} ${OUT_FN} &

done

echo "Wait for R"
wait

done
done
