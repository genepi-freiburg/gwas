SCRIPT=${GWAMA_CONVERT}

LOG_FILE=${LOG_DIR}/convert-snptest.log
touch ${LOG_FILE}

ADJS="unadjusted adjusted"

PHEN_TYPE_ARRAY=(${PHENOTYPE_TYPES})
PHEN_IDX=0
for PHEN in ${PHENOTYPE_NAMES}
do

PHEN_TYP=${PHEN_TYPE_ARRAY[${PHEN_IDX}]}
PHEN_IDX=$(expr $PHEN_IDX + 1)

PHEN_TYP_CODE="SE"
if [ "${PHEN_TYP}" == "B" ]
then
	PHEN_TYP_CODE="OR"
fi

echo "Process ${PHEN} (idx ${PHEN_IDX}, type ${PHEN_TYP}, code ${PHEN_TYP_CODE})" | tee -a ${LOG_FILE}

mkdir -p ${DATA_DIR}/input/${PHEN}

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

#CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
# further down is another CHRS !!
CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"

for CHR in ${CHRS}
do

MY_SNPTEST_FILE=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHEN}/g | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${FN}/g`
MY_GWAMA_FILE="${DATA_DIR}/input/${PHEN}/${FN}-${ADJ}-chr${CHR}.gwama"

if [ -f "${MY_GWAMA_FILE}" ]
then
	echo "Exists/Skip: ${FN} ${ADJ} ${PHEN} Chr ${CHR}" | tee -a ${LOG_FILE}
else
	echo "Convert ${FN} ${ADJ} ${PHEN} Chr ${CHR}: ${MY_SNPTEST_FILE} -> ${MY_GWAMA_FILE}" | tee -a ${LOG_FILE}
	perl ${SCRIPT} ${MY_SNPTEST_FILE} ${MY_GWAMA_FILE} ${PHEN_TYP_CODE} MAF=${MAF} N=${MINN} &
	${SCRIPT_DIR}/wait-perl.sh
fi

#CHR
done

echo "Wait for remaining perls (finishing all chromosomes of ${PHEN} ${FN} ${ADJ})" | tee -a ${LOG_FILE}
wait

MY_PHEN_OUT_DIR="${DATA_DIR}/input/${PHEN}"
echo "Merging ${PHEN} ${FN} ${ADJ}, dir: ${MY_PHEN_OUT_DIR}" | tee -a ${LOG_FILE}
mv ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}-chr1.gwama ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}.gwama
#CHRS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
CHRS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"
for CHR in ${CHRS}
do
cat ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}-chr${CHR}.gwama | tail -n+2 >>${MY_PHEN_OUT_DIR}/${FN}-${ADJ}.gwama
done
#rm -v ${MY_PHEN_OUT_DIR}/${FN}-${ADJ}-chr*.gwama

# ADJ
done

# FN
done

# PHEN
done

echo "Finish"
