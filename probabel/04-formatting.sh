CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"
GWAS_OUT_DIR=${DATA_DIR}/gwasqc
PROB_OUT_DIR=${DATA_DIR}/out
FREQ_DIR=${DATA_DIR}/freq
mkdir -p ${GWAS_OUT_DIR}

for COHORT in ${COHORTS}
do

        for CHR in ${CHRS}
        do
		echo "Format ${COHORT} ${CHR}"

                FREQ_FILE=${FREQ_DIR}/${COHORT}-chr${CHR}.snp-freqs.txt

		Rscript ${SCRIPT_DIR}/probabel2gwas.R \
			${PROB_OUT_DIR}/${COHORT}-chr${CHR}_add.out.txt \
			${GWAS_OUT_DIR}/${COHORT}-chr${CHR}.gwas \
			${FREQ_FILE} &

		#Rscript ${SCRIPT_DIR}/gwcoxph2gwas.R \
		#	${PROB_OUT_DIR}/gw-coxph-${COHORT}-chr${CHR}.txt \
                #	${GWAS_OUT_DIR}/${COHORT}-chr${CHR}.gwas \
		#	${FREQ_FILE} \
		#	${CHR} &

	done

	echo "Waiting for remaining chromosomes"
	wait

	head -n 1 ${GWAS_OUT_DIR}/${COHORT}-chr1.gwas > ${GWAS_OUT_DIR}/${COHORT}.gwas
	for CHR in ${CHRS}
	do
		tail -n+2 ${GWAS_OUT_DIR}/${COHORT}-chr${CHR}.gwas >> ${GWAS_OUT_DIR}/${COHORT}.gwas
	done
	rm -fv ${GWAS_OUT_DIR}/${COHORT}-chr*.gwas
done

