#SNP     chr     position        coded_all       noncoded_all    strand_genome   beta    SE      pval    AF_coded_all    HWE_pval        callrate        n_total imputed used_for_imp    oevar_imp
#  danach: cases_hwe controls_hwe wenn moeglich

ADJS="adjusted unadjusted"
if [ "${SKIP_UNADJUSTED}" == 1 ]
then
	ADJS="adjusted"
fi

for PHENO in ${PHENOTYPE_NAMES}
do

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

	echo "Filter ${PHENO} ${FN} ${ADJ}, min p ${MINP}"
	INFN=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHENO}/g | sed s/%COHORT%/${FN}/g`
	OUT_DIR="${DATA_DIR}"
	OUT_FN="${OUT_DIR}/filtered-${FN}-${PHENO}-${ADJ}.gwas"
	mkdir -p ${OUT_DIR}
	head -n 1 ${INFN} > ${OUT_FN}
	export P_BORDER HWE_BORDER MAF_BORDER
	echo "Infile: ${INFN}, Outfile: ${OUT_FN}"
	cat ${INFN} | perl ${SCRIPT_DIR}/filter.pl >> ${OUT_FN} &

	${SCRIPT_DIR}/wait-perl.sh

done
done
done

echo Waiting for last jobs
wait
RC=$?
if [ "$RC" != "0" ];
then
	echo "Error filtering files!"
	exit 9
fi



for PHENO in ${PHENOTYPE_NAMES}
do

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

	echo "Find independent SNPs for ${PHENO} ${FN} ${ADJ}"
	echo "(This also writes LocusZoom hitspec file.)"
	INFN="${OUT_DIR}/filtered-${FN}-${PHENO}-${ADJ}.gwas"
	OUTFN="${OUT_DIR}/independent-${FN}-${PHENO}-${ADJ}.txt"
	/usr/local/R/R-3.4.1/bin/Rscript ${SCRIPT_DIR}/myindepv5.R ${INFN} ${OUTFN} ${SCRIPT_DIR} 2>&1 | tee ${LOG_DIR}/indep-${FN}-${PHENO}-${ADJ}.log
done
done
done
