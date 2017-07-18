${PLINK} --noweb \
	--bfile ${INTERMED_FILE} \
	--maf ${MAF} \
	--make-bed \
	--out ${INTERMED_FILE}
