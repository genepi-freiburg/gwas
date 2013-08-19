${PLINK} --noweb \
	--bfile ${INTERMED_FILE} \
	--hwe ${HWE} \
	--make-bed \
	--out ${INTERMED_FILE}
