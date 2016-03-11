CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"
GWAS_OUT_DIR=${DATA_DIR}/gwasqc
PROB_OUT_DIR=${DATA_DIR}/out
FREQ_DIR=${DATA_DIR}/freq
mkdir -p ${GWAS_OUT_DIR}

for COHORT in ${COHORTS}
do

        for CHR in ${CHRS}
        do
		echo "Format ${COHORT} ${CHR}" | tee ${LOG_DIR}/formatting-results-global.txt

                FREQ_FILE=${FREQ_DIR}/${COHORT}-chr${CHR}.snp-freqs.txt

		FREQ_MAP_FILE=""
		if [ "${FREQ_SNP_MAP_PATH}" != "" ]
		then
	                FREQ_MAP_FILE=`echo ${FREQ_SNP_MAP_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${COHORT}/g`
			echo "Map frequency SNPs using $FREQ_MAP_FILE" | tee ${LOG_DIR}/formatting-results-global.txt
		else
			echo "No need to map frequency SNPs" | tee ${LOG_DIR}/formatting-results-global.txt
		fi

		Rscript ${SCRIPT_DIR}/probabel2gwas.R \
			${PROB_OUT_DIR}/${COHORT}-chr${CHR}_add.out.txt \
			${GWAS_OUT_DIR}/${COHORT}-chr${CHR}.gwas \
			${FREQ_FILE} ${FREQ_MAP_FILE} \
			2>&1 | tee ${LOG_DIR}/formatting-results-${COHORT}-chr${CHR}.log &

	done

	echo "Waiting for remaining chromosomes" | tee ${LOG_DIR}/formatting-results-global.txt
	wait

	head -n 1 ${GWAS_OUT_DIR}/${COHORT}-chr1.gwas > ${GWAS_OUT_DIR}/${COHORT}.gwas
	for CHR in ${CHRS}
	do
		tail -n+2 ${GWAS_OUT_DIR}/${COHORT}-chr${CHR}.gwas >> ${GWAS_OUT_DIR}/${COHORT}.gwas
	done
	rm -fv ${GWAS_OUT_DIR}/${COHORT}-chr*.gwas
done

