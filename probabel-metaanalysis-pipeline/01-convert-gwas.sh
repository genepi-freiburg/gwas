SCRIPT=${SCRIPT_DIR}/gwas2gwama.pl

LOG_FILE=${LOG_DIR}/convert-gwas.log
touch ${LOG_FILE}

mkdir -p ${DATA_DIR}/input

for FN in ${ALL_COHORTS}
do

MY_GWAS_FILE=`echo ${GWAS_OUTPUT} | sed s/%COHORT%/${FN}/g`
MY_GWAMA_FILE="${DATA_DIR}/input/${FN}.gwama"

if [ -f "${MY_GWAMA_FILE}" ]
then
	echo "Exists/Skip: ${FN}" | tee -a ${LOG_FILE}
else
	echo "Convert ${FN}: ${MY_GWAS_FILE} -> ${MY_GWAMA_FILE}" | tee -a ${LOG_FILE}
	rm -f ${MY_GWAMA_FILE}
	perl ${SCRIPT} ${MY_GWAS_FILE} ${MY_GWAMA_FILE} MAF=${MAF} N=${MINN} &
fi

done

echo "Wait for Convert jobs" | tee -a ${LOG_FILE}
wait
echo "Finish"
