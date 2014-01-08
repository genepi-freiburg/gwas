DIR=${0%/*}
. ${DIR}/parameters.sh

FAIL_INDIV=$3
if [ "${FAIL_INDIV}" == "" ]
then
	echo "Usage: $0 path basename fail-indiv-file"
	exit 9
fi

INTERMED_FILE=${TEMP_DIR}/filtered

log_stats() {
	cat ${INTERMED_FILE}.log | egrep "^[0-9]+ cases, .* controls and .* missing" >> ${MAIN_LOG_FILE}
	cat ${INTERMED_FILE}.log | egrep "^[0-9]+ males, .* females, and .* of unspecified sex" >> ${MAIN_LOG_FILE}
        cat ${INTERMED_FILE}.log | egrep "After frequency and genotyping pruning, there are [0-9]+ SNPs" >> ${MAIN_LOG_FILE}
}

echo "Using failing individual file: ${FAIL_INDIV}"

echo -n "MAF filter [${MAF_DEFAULT}]: "
read MAF
if [ "${MAF}" == "" ]
then
	MAF=${MAF_DEFAULT}
fi

echo -n "GENO filter (callrate) [${GENO_DEFAULT}]: "
read GENO
if [ "${GENO}" == "" ]
then
	GENO=${GENO_DEFAULT}
fi

echo -n "HWE filter []: "
read HWE

log "filter individuals"
. ${SCRIPT_DIR}/filter/01-filter-individuals.sh
log_stats

if [ "${MAF}" != "" ]
then
	log "apply MAF filter ${MAF}"
	. ${SCRIPT_DIR}/filter/02-maf-filter.sh
	log_stats
else
	log "no MAF filter"
fi

if [ "${GENO}" != "" ]
then
        log "apply GENO filter ${GENO}"
        . ${SCRIPT_DIR}/filter/03-geno-filter.sh
	log_stats
else
	log "no GENO filter"
fi

if [ "${HWE}" != "" ]
then
	log "apply HWE filter ${HWE}"
        . ${SCRIPT_DIR}/filter/04-hwe-filter.sh
        log_stats
else
	log "no HWE filter"
fi

if [ -f "${INTERMED_FILE}.hh" ]
then
	log "remove heterozygous haploid SNPs"
        . ${SCRIPT_DIR}/filter/05-haploid-filter.sh
	log_stats
fi

mv ${TEMP_DIR}/filtered.bed ${SOURCE_FILE}_final.bed
mv ${TEMP_DIR}/filtered.bim ${SOURCE_FILE}_final.bim
mv ${TEMP_DIR}/filtered.fam ${SOURCE_FILE}_final.fam

