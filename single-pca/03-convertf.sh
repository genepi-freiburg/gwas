cat ${SCRIPT_DIR}/03-convertf.par | \
	sed s:06-cleanind-pca:${OUTPUT_DIR}/03-${PREFIX}:g | \
	sed s:07-cleanind-pca:${OUTPUT_DIR}/04-${PREFIX}:g \
	> ${OUTPUT_DIR}/03-convertf-${PREFIX}.par

/opt/eigenstrat/bin/convertf -p ${OUTPUT_DIR}/03-convertf-${PREFIX}.par

