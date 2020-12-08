CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"

FREQ_DIR=${DATA_DIR}/freq
PHENO_DIR=${DATA_DIR}/phenotypes

mkdir -p ${FREQ_DIR}

for COHORT in ${COHORTS}
do

	for CHR in ${CHRS}
	do

		echo "Calculate frequencies for ${COHORT} - chr${CHR}"

		# use imputation results here
		GEN_FILE=`echo ${GEN_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${COHORT}/g`
		SAMPLE_FILE=`echo ${SAMPLE_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${COHORT}/g`
		KEEP_INDIV_FILE=${PHENO_DIR}/phenotype_${COHORT}.txt.keep

		FREQ_OUT_FILE=${FREQ_DIR}/${COHORT}-chr${CHR}.snp-freqs.txt

		if [ -f ${FREQ_OUT_FILE} ];
		then
			echo "Frequency file exists - skip"
		else
			${SCRIPT_DIR}/calculate-snp-freqs.sh ${GEN_FILE} ${SAMPLE_FILE} ${KEEP_INDIV_FILE} ${FREQ_OUT_FILE} &
		fi
	done

	echo "Wait"
	wait


	echo "Cohort ${COHORT} finished; clean-up temp"
	rm -rf /scratch/local/mw_freq_temp

done

echo "All cohorts finished with frequencies"
