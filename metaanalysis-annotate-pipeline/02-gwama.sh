ADJS="unadjusted adjusted"

GWAMA_LOG_DIR="${DATA_DIR}/log"
mkdir -p ${GWAMA_LOG_DIR}

PHEN_TYPE_ARRAY=(${PHENOTYPE_TYPES})
PHEN_IDX=0

for PHEN in ${PHENOTYPE_NAMES}
do

PHEN_TYP=${PHEN_TYPE_ARRAY[${PHEN_IDX}]}
PHEN_IDX=$(expr $PHEN_IDX + 1)

PHEN_TYP_CODE="-qt"
if [ "${PHEN_TYP}" == "B" ]
then
        PHEN_TYP_CODE=""
fi

for ADJ in ${ADJS}
do

for GROUP in ${METAANALYSIS_GROUPS}
do

echo ${PHEN} ${ADJ} ${GROUP}


GWAMA_IN_FILE="${DATA_DIR}/input/${PHEN}/gwama-${GROUP}-${ADJ}.in"
rm -f ${GWAMA_IN_FILE}
touch ${GWAMA_IN_FILE}

eval "MEMBERS=\$GROUPS_${GROUP}"
echo "Group: ${GROUP}, Members: ${MEMBERS}"
for MEMBER in ${MEMBERS}
do
	echo ${DATA_DIR}/input/${PHEN}/${MEMBER}-${ADJ}.gwama >>${GWAMA_IN_FILE}
done

echo "Gwama Input File ${GWAMA_IN_FILE}:"
cat ${GWAMA_IN_FILE}
echo "End of Input File"

GWAMA_OUT_DIR="${DATA_DIR}/output/${PHEN}"
GWAMA_OUT_FILE="${GWAMA_OUT_DIR}/gwama-${GROUP}-${ADJ}"
mkdir -p ${GWAMA_OUT_DIR}

${GWAMA} ${PHEN_TYP_CODE} -gc -gco \
	-i ${GWAMA_IN_FILE} \
	-o ${GWAMA_OUT_FILE} \
	--indel_alleles \
	 2>&1 > ${GWAMA_LOG_DIR}/gwama-${PHEN}-${ADJ}-${GROUP}.stdout.txt &

# GROUP
done

echo "Waiting for GWAMA to finish ${PHEN} - ${ADJ}"
wait

# ADJ
done

#echo "Waiting for GWAMA to finish ${PHEN}"
#wait

# PHEN
done

