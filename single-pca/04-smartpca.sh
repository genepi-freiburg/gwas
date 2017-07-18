if [ -f ${OUTPUT_DIR}/05-${PREFIX}.evec ]
then
	echo "EVEC present - skip step"
else

	cat ${SCRIPT_DIR}/04-smartpca.par | \
		sed s:07-cleanind-pca:${OUTPUT_DIR}/04-${PREFIX}:g | \
		sed s:08-cleanind-pca:${OUTPUT_DIR}/05-${PREFIX}:g | \
	        sed s/10/${PC_COUNT}/g \
		> ${OUTPUT_DIR}/04-smartpca-${PREFIX}.par

	/opt/eigenstrat/bin/smartpca -p ${OUTPUT_DIR}/04-smartpca-${PREFIX}.par

fi
