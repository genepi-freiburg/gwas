#SNP     chr     position        coded_all       noncoded_all    strand_genome   beta    SE      pval    AF_coded_all    HWE_pval        callrate        n_total imputed used_for_imp    oevar_imp


ADJS="adjusted unadjusted"

for PHENO in ${PHENOTYPE_NAMES}
do

for ADJ in ${ADJS}
do

	echo "Filter ${PHENO} ${ADJ}"
	MY_SNPTEST_FILE=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHEN}/g`
	OUT_DIR="${DATA_DIR}"
	OUT_FN="${OUT_DIR}/filtered-${PHENO}-${ADJ}.gwas"
	mkdir -p ${OUT_DIR}
	head -n 1 ${INFN} > ${OUT_FN}
	export MINP
	cat ${INFN} | perl ${SCRIPT_DIR}/filter.pl >> ${OUT_FN} &

	${SCRIPT_DIR}/wait-perl.sh

done
done

echo Waiting for last jobs
wait

