ADJS="adjusted unadjusted"

if [ "${SKIP_UNADJUSTED_ANALYSIS}" == "1" ]
then
	ADJS="adjusted"
fi

export PROCESS_LIMIT

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
	OUTFILE="${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr${CHR}.gwas"
	if [ -f ${OUTFILE} ]
	then
		echo "File exists: ${OUTFILE} - skip" | tee -a ${FORMATTING_LOG}
	else
		${SCRIPT_DIR}/formatting.pl \
			-i ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr${CHR}.out \
			-c ${CHR} \
			-o ${OUTFILE} \
			2>&1 | tee -a ${FORMATTING_LOG} &
		${SCRIPT_DIR}/wait-perl.sh
	fi
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

	FIRST_FILE=`ls ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr*.gwas | head -n 1`
	echo "First file (for header) is: $FIRST_FILE"
	head -n 1 ${FIRST_FILE} >${DATA_DIR}/${PHEN}/${ADJ}/${FN}.gwas
	for CHR in ${CHRS}
	do
		sed -e '1d' ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr${CHR}.gwas \
			>>${DATA_DIR}/${PHEN}/${ADJ}/${FN}.gwas
	done
	rm ${DATA_DIR}/${PHEN}/${ADJ}/${FN}-chr*.gwas

done
done
done

if [ "${SNP_TRANSLATION_TABLE}" != "" ]
then

echo "Add RSID alias column, translate using ${SNP_TRANSLATION_TABLE}" >>${FORMATTING_LOG}
echo "Add RSID alias column, translate using ${SNP_TRANSLATION_TABLE}"

for PHEN in ${PHENOTYPE_NAMES}
do
for FN in ${COHORTS}
do
for ADJ in ${ADJS}
do

GWAS_FN="${DATA_DIR}/${PHEN}/${ADJ}/${FN}.gwas"
echo "Working with: ${GWAS_FN}"

mv "${GWAS_FN}" "${GWAS_FN}.orig"	
${SCRIPT_DIR}/../utils/update-gwas-by-map.pl \
	-g "${GWAS_FN}.orig" \
	-m "${SNP_TRANSLATION_TABLE}" \
	-o "${GWAS_FN}" \
	-s

done
done
done

else

echo "No RSID translation" >>${FORMATTING_LOG}
echo "No RSID translation"

fi

if [ "${INFO_TRANSLATION_TABLE}" != "" ]
then

echo "Replace SNPtest info with Rsq for imputation quality, using ${INFO_TRANSLATION_TABLE}" >>${FORMATTING_LOG}
echo "Replace SNPtest info with Rsq for imputation quality, using ${INFO_TRANSLATION_TABLE}"

for PHEN in ${PHENOTYPE_NAMES}
do
for FN in ${COHORTS}
do
for ADJ in ${ADJS}
do

GWAS_FN="${DATA_DIR}/${PHEN}/${ADJ}/${FN}.gwas"
echo "Working with: ${GWAS_FN}"

mv "${GWAS_FN}" "${GWAS_FN}.orig1"
${SCRIPT_DIR}/update-gwas-by-Rsq.pl \
        -g "${GWAS_FN}.orig1" \
        -m "${INFO_TRANSLATION_TABLE}" \
        -o "${GWAS_FN}"
rm "${GWAS_FN}.orig1"

done
done
done

else

echo "No Rsq replacement" >>${FORMATTING_LOG}
echo "No Rsq replacement"

fi


echo "Done" | tee -a ${FORMATTING_LOG}
