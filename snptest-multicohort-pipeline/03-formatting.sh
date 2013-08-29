ADJS="adjusted unadjusted"
#CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"
# there is another CHRS statement further down!!

FORMATTING_LOG="${DATA_DIR}/log/formatting.log"
rm -f ${FORMATTING_LOG}
touch ${FORMATTING_LOG}

for PHEN in ${PHENOTYPE_NAMES}
do
for FN in ${COHORTS}
do
for ADJ in ${ADJS}
do
for CHR in ${CHRS}
do
	echo Format ${FN} ${CHR} ${ADJ} ${PHEN}
	${SCRIPT_DIR}/formatting.pl -i ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr${CHR}.out -c ${CHR} -o ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr${CHR}.gwas 2>&1 | tee -a ${FORMATTING_LOG} &
	${SCRIPT_DIR}/wait-perl.sh
done
done
done
done

echo "Waiting for remaining formatting jobs"
wait

echo "Merge files" >>${FORMATTING_LOG}

for PHEN in ${PHENOTYPE_NAMES}
do
for FN in ${COHORTS}
do
for ADJ in ${ADJS}
do

echo "Combine ${FN} ${ADJ} ${PHEN}" | tee -a ${FORMATTING_LOG}

cat ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr1.gwas >${DATA_DIR}/${ADJ}/${FN}.gwas
#CHRS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
CHRS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"
for CHR in ${CHRS}
do
	sed -e '1d' ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr${CHR}.gwas >>${ADJ}/${FN}.gwas
done
rm ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr*.gwas

done
done

echo Done | tee ${FORMATTING_LOG}
