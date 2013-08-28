echo "Preparing phenotypes: ${PHENOTYPE_FILE}"
export FAM_PATH
export DATA_DIR
export PHENOTYPE_NAMES
export PHENOTYPE_FILE
export COHORTS
export PHENOTYPE_TYPES
mkdir -p ${DATA_DIR}/sample
Rscript ${SCRIPT_DIR}/01-prepare-sample.R | tee ${LOG_DIR}/prepare-sample.log
