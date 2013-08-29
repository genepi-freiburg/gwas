ADJS="unadjusted adjusted"
GWAMA=~/bin/gwama/GWAMA

GWAMA_LOG_DIR="${DATA_DIR}/log"
mkdir -p ${GWAMA_LOG_DIR}

for PHEN in ${PHENOTYPE_NAMES}
do

for ADJ in ${ADJS}
do

for GROUP in ${GROUPS}
do

echo ${PHEN} ${ADJ} ${GROUP}


GWAMA_IN_FILE="${DATA_DIR}/input/${PHEN}/gwama-${GROUP}-${ADJ}.in"
rm -f ${GWAMA_IN_FILE}
touch ${GWAMA_IN_FILE}

eval "MEMBERS=\$GROUP_${GROUP}"
for MEMBER in MEMBERS
do
	echo ${DATA_DIR}/input/${PHEN}/${MEMBER}-${ADJ}.gwama >>${GWAMA_IN_FILE}
done

echo "Gwama Input File ${GWAMA_IN_FILE}:"
cat ${GWAMA_IN_FILE}

GWAMA_OUT_DIR="${DATA_DIR}/output/${PHEN}"
GWAMA_OUT_FILE="${GWAMA_OUT_DIR}/gwama-${GROUP}-${ADJ}"
mkdir -p ${GWAMA_OUT_DIR}

${GWAMA} -qt -gc -gco \
	-i ${GWAMA_IN_FILE} \
	-o ${GWAMA_OUT_FILE} \
	--indel_alleles \
	 2>&1 > ${GWAMA_LOG_DIR}/gwama-${PHEN}-${ADJ}-${GROUP}.stdout.txt &

# GROUP
done

# ADJ
done

echo "Waiting for GWAMA to finish ${PHEN}"
wait

# PHEN
done

