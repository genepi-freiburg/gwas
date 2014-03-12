CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"

export PROCESS_LIMIT

if [ "${FREQUENTIST_MODEL}" == "" ]
then
	FREQUENTIST_MODEL=1
fi

for FN in ${COHORTS}
do

for PHEN in ${PHENOTYPE_NAMES}
do

mkdir -p ${DATA_DIR}/${PHEN}/adjusted
mkdir -p ${DATA_DIR}/${PHEN}/unadjusted

EIGEN=""
EIGENS=`cat ${COVARIATE_FILE} | grep ${FN} | grep ^${PHEN} | cut -f 3 -d ' '`
for EIG in ${EIGENS}
do
  if [ "${EIGEN}" == "" ]
  then
    EIGEN=${EIG}
  else
    EIGEN="${EIGEN} ${EIG}"
  fi
done

COV="AGE SEX ${EIGEN}"

for CHR in ${CHRS}
do

echo Processing ${FN} - ${PHEN} - Chromosome ${CHR}

GENFILE=`echo ${GEN_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${FN}/g`
	
echo "Analysis with Covariate Adjustment: ${COV}"
echo "Using GEN file: ${GENFILE}"
echo "Using SAMPLE file: ${DATA_DIR}/sample/${FN}.sample"
	
#-total_prob_limit 0 \

if [ "${RAW_PHENOTYPES}" == "1" ]
then

${SNPTEST} \
        -data ${GENFILE} ${DATA_DIR}/sample/${FN}.sample \
        -o ${DATA_DIR}/${PHEN}/adjusted/${FN}-chr${CHR}.out \
        -frequentist ${FREQUENTIST_MODEL} \
        -method expected \
        -hwe \
        -pheno ${PHEN} \
        -lower_sample_limit 50 \
        -assume_chromosome ${CHR} \
        -cov_names ${COV} \
        -log ${DATA_DIR}/log/snptest-${PHEN}-adjusted-${FN}-chr${CHR}.log \
	-use_raw_phenotypes \
        >/dev/null &

else

${SNPTEST} \
	-data ${GENFILE} ${DATA_DIR}/sample/${FN}.sample \
	-o ${DATA_DIR}/${PHEN}/adjusted/${FN}-chr${CHR}.out \
	-frequentist ${FREQUENTIST_MODEL} \
	-method expected \
	-hwe \
	-pheno ${PHEN} \
	-lower_sample_limit 50 \
	-assume_chromosome ${CHR} \
	-cov_names ${COV} \
	-log ${DATA_DIR}/log/snptest-${PHEN}-adjusted-${FN}-chr${CHR}.log \
	>/dev/null &

fi

${SCRIPT_DIR}/wait-snptest.sh

if [ "${SKIP_UNADJUSTED_ANALYSIS}" != "1" ]
then
echo "Unadjusted Analysis"

if [ "${RAW_PHENOTYPES}" == "1" ]
then

${SNPTEST} \
        -data ${GENFILE} ${DATA_DIR}/sample/${FN}.sample \
        -o ${DATA_DIR}/${PHEN}/unadjusted/${FN}-chr${CHR}.out \
        -frequentist ${FREQUENTIST_MODEL} \
        -method expected \
        -hwe \
        -pheno ${PHEN} \
        -lower_sample_limit 50 \
        -assume_chromosome ${CHR} \
        -log ${DATA_DIR}/log/snptest-${PHEN}-unadjusted-${FN}-chr${CHR}.log \
        >/dev/null &

else

${SNPTEST} \
        -data ${GENFILE} ${DATA_DIR}/sample/${FN}.sample \
	-o ${DATA_DIR}/${PHEN}/unadjusted/${FN}-chr${CHR}.out \
        -frequentist ${FREQUENTIST_MODEL} \
        -method expected \
        -hwe \
        -pheno ${PHEN} \
        -lower_sample_limit 50 \
        -assume_chromosome ${CHR} \
        -log ${DATA_DIR}/log/snptest-${PHEN}-unadjusted-${FN}-chr${CHR}.log \
        -use_raw_phenotypes \
        >/dev/null &

fi

${SCRIPT_DIR}/wait-snptest.sh
else
echo "Skip unadjusted analysis"
fi

echo "Chromosome ${CHR} done"
done

if [ "${SKIP_CHR_X}" != "1" ]
then

# X_nonPAR adjusted
CHR=X_nonPAR
echo Processing ${FN} - ${PHEN} - Chromosome ${CHR}

GENFILE=`echo ${GEN_PATH} | sed s/%CHR%/${CHR}/g | sed s/%COHORT%/${FN}/g`

echo "Analysis with Covariate Adjustment: ${COV}"
echo "Using GEN file: ${GENFILE}"
echo "Using SAMPLE file: ${DATA_DIR}/sample/${FN}.sample"

#-total_prob_limit 0 \

${SNPTEST} \
        -data ${GENFILE} ${DATA_DIR}/sample/${FN}.sample \
        -o ${DATA_DIR}/${PHEN}/adjusted/${FN}-chr${CHR}.out \
        -frequentist ${FREQUENTIST_MODEL} \
        -method newml \
	-sex_column SEX \
        -hwe \
	-assume_chromosome 0X \
        -pheno ${PHEN} \
        -lower_sample_limit 50 \
        -cov_names ${COV} \
        -log ${DATA_DIR}/log/snptest-${PHEN}-adjusted-${FN}-chr${CHR}.log \
        >/dev/null &

${SCRIPT_DIR}/wait-snptest.sh

if [ "${SKIP_UNADJUSTED_ANALYSIS}" != "1" ]
then

echo "Unadjusted Analysis"

${SNPTEST} \
        -data ${GENFILE} ${DATA_DIR}/sample/${FN}.sample \
        -o ${DATA_DIR}/${PHEN}/unadjusted/${FN}-chr${CHR}.out \
        -frequentist ${FREQUENTIST_MODEL} \
        -method newml \
        -sex_column SEX \
        -assume_chromosome 0X \
        -hwe \
        -pheno ${PHEN} \
        -lower_sample_limit 50 \
        -log ${DATA_DIR}/log/snptest-${PHEN}-unadjusted-${FN}-chr${CHR}.log \
        >/dev/null &

${SCRIPT_DIR}/wait-snptest.sh
else
echo "Skip unadjusted analysis"
fi

fi

echo "Phenotype ${PHENO} done"
done

echo "File ${FN} done"
done

echo "Waiting for remaining jobs"
wait
echo Done
