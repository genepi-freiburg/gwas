
PHENO_DIR=${DATA_DIR}/phenotypes
mkdir -p ${PHENO_DIR}

for COHORT in ${COHORTS}
do
	echo "Generate phenotype file for ${COHORT}"

	## determine covariates

	COVARIATES="${FIXED_COVARIATES}"
	COVAR_FILE_CONTENT=`cat ${COVARIATE_FILE} | grep ^${COHORT} | cut -f 2 -d ' '`
	for COV in ${COVAR_FILE_CONTENT}
	do
		if [ "${COVARIATES}" == "" ]
  		then
    			COVARIATES=${COV}
  		else
    			COVARIATES="${COVARIATES},${COV}"
  		fi
	done
	echo "Covariates: ${COVARIATES}"
	echo "Covariate file: ${COVARIATE_FILE}"

	## determine MLDOSE file

	MLDOSE_FILE=`echo ${MLDOSE_PATH} | sed s/%CHR%/1/g | sed s/%COHORT%/${COHORT}/g`

	Rscript ${SCRIPT_DIR}/merge_pheno_info.R \
		${PHENOTYPE_FILE} ${MLDOSE_FILE} \
		${IID_COLUMN} ${SURV_TIME_COLUMN} ${EVENT_COLUMN} \
		${PHENO_DIR}/phenotype_${COHORT}.txt \
	 	${COVARIATES} \
		| tee ${LOG_DIR}/phenotype_${COHORT}.log

done
