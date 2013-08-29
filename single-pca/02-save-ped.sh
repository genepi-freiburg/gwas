/usr/lib/plink/plink \
        --noweb \
        --recode \
        --bfile ${SOURCE_FILE} \
        --output-missing-phenotype 1 \
	--extract ${OUTPUT_DIR}/02-${PREFIX}-exclude-high-LD-snps.prune.in \
        --out ${OUTPUT_DIR}/03-${PREFIX}
