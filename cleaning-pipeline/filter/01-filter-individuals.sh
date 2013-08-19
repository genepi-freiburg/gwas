${PLINK} --noweb \
	--bfile ${SOURCE_NOF_FILE} \
	--remove ${FAIL_INDIV} \
	--make-bed \
	--out ${INTERMED_FILE}
