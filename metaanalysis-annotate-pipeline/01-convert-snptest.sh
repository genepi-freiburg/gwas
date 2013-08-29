SCRIPT=${GWAMA_CONVERT}


#CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"
ADJS="unadjusted adjusted"

for PHEN in ${PHENOTYPE_NAMES}
do

mkdir -p ${DATA_DIR}/input/${PHEN}

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

for CHR in ${CHRS}
do

MY_SNPTEST_FILE=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHEN}/g | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${FN}/g`
echo "${FN} ${ADJ} ${PHEN} Chr ${CHR}: ${MY_SNPTEST_FILE}"
perl ${SCRIPT} ${MY_SNPTEST_FILE} ${DATA_DIR}/input/${PHEN}/${FN}-${ADJ}-chr${CHR}.gwama SE MAF=${MAF} N=${MINN} &

./wait-perl.sh

done

echo "Wait for remaining perls (finishing all chromosomes of ${PHEN} ${FN} ${ADJ})"
wait

echo "Merging ${PHEN} ${FN} ${ADJ}"
MY_PHEN_OUT_DIR=${DATA_DIR}/input/${PHEN}
mv ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}-chr1.gwama ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}.gwama
CHRS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
for CHR in ${CHRS}
do
cat ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}-chr${CHR}.gwama | tail -n+2 >>${MY_PHEN_OUT_DIR}/${FN}-${ADJ}.gwama
done
rm ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}-chr*.gwama

done
done
done

echo "Finish"
