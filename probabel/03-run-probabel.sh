CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
PHENO_DIR=${DATA_DIR}/phenotypes

OUT_DIR=${DATA_DIR}/out
mkdir -p ${OUT_DIR}

for COHORT in ${COHORTS}
do

	for CHR in ${CHRS}
	do

		echo "Process ${COHORT} - chr${CHR}"

	        MLDOSE_FILE=`echo ${MLDOSE_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${COHORT}/g`
	        MLINFO_FILE=`echo ${MLINFO_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${COHORT}/g`
	        MAP_FILE=`echo ${MAP_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${COHORT}/g`

		${PROBABEL} --pheno ${PHENO_DIR}/phenotype_${COHORT}.txt \
			--info ${MLINFO_FILE} \
			--dose ${MLDOSE_FILE} \
			--map ${MAP_FILE} \
			--chrom ${CHR} \
			--out ${OUT_DIR}/${COHORT}-chr${CHR} \
			2>&1 | tee ${LOG_DIR}/probabel-${COHORT}-chr${CHR}.log &
	done

	echo "Wait"
	wait
done
