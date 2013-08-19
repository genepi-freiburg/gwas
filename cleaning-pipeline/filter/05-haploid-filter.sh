cat ${INTERMED_FILE}.hh | cut -f 3 | sort | uniq \
	>${TEMP_DIR}/het-hapl-snps.txt
COUNT=`wc -l ${TEMP_DIR}/het-hapl-snps.txt`
log "excluding ${COUNT} SNPs because they have got male heterozygous haploid genotypes"

${PLINK} --noweb \
	--bfile ${INTERMED_FILE} \
	--exclude ${TEMP_DIR}/het-hapl-snps.txt \
	--make-bed \
	--out ${INTERMED_FILE}
