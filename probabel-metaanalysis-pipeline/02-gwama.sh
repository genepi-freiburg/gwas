for GROUP in ${METAANALYSIS_GROUPS}
do

echo "Metaanalysis: ${GROUP}"

GWAMA_IN_FILE="${DATA_DIR}/input/gwama-${GROUP}.in"
rm -f ${GWAMA_IN_FILE}
touch ${GWAMA_IN_FILE}

eval "MEMBERS=\$GROUPS_${GROUP}"
echo "Group: ${GROUP}, Members: ${MEMBERS}"
for MEMBER in ${MEMBERS}
do
        echo ${DATA_DIR}/input/${MEMBER}.gwama >>${GWAMA_IN_FILE}
done

echo "Gwama Input File ${GWAMA_IN_FILE}:"
cat ${GWAMA_IN_FILE}
echo "End of Input File"

GWAMA_OUT_DIR="${DATA_DIR}/output"
GWAMA_OUT_FILE="${GWAMA_OUT_DIR}/gwama-${GROUP}"
mkdir -p ${GWAMA_OUT_DIR}

if [ "${GC_OPTS}" == "" ]
then
        GC_OPTS="-gc -gco"
fi

MAP_FILE=/data/gwas/pediGFR_gwas/Metaanalysis/Imputed/map/ALL_1000G.map

${GWAMA} -qt \
	${GC_OPTS} \
	-i ${GWAMA_IN_FILE} \
	-o ${GWAMA_OUT_FILE} \
	--indel_alleles \
	--map ${MAP_FILE} \
	 2>&1 > ${GWAMA_OUT_FILE}.log &

done

echo "Waiting for groups"
wait
