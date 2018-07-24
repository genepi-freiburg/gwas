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
    LZDIR="${DATA_DIR}/locuszoom/${PHENO}/${FN}_${ADJ}"
    mkdir -p "${LZDIR}"

    # make not-so-funny rsids
    OUTFN="${DATA_DIR}/independent-${FN}-${PHENO}-${ADJ}.txt"
    GWAS_FILE=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHENO}/g | sed s/%COHORT%/${FN}/g`
    PVAL_FN="${LZDIR}/pvalues.txt"

    MAF=$LOCUSZOOM_MAF_FILTER
    if [ "$MAF" == "" ]
    then
	MAF=0.05
    fi
    echo "Using MAF filter for LocusZoom: $MAF"

    HWE=$HWE_BORDER

    # generate Metal file
    echo "Generate Metal file: ${PVAL_FN}, with MAF filter $MAF and HWE filter $HWE"
    wc -l ${GWAS_FILE}
    cat ${GWAS_FILE} \
    | awk -v maf=$MAF -v hwe=$HWE 'BEGIN {
               OFS = "\t"
           };
           { 
               if (NR == 1) {
                   print "MarkerName", "P-value" 
               } else {
                   if ($10 >= maf && $10 <= 1-maf && $11 > hwe) {
                       if ($1 ~ /^rs.*:/) {
                           print substr($1, 1, index($1, ":")-1), $9 
                       } else {
                           print $1, $9 
                       }
                   }
               }
	   }' > ${PVAL_FN}
    echo "Done generating/filtering - row count:"
    wc -l $PVAL_FN

    HITSPEC="${OUTFN}.hitspec"
    echo "LocusZoom Dir: $LZDIR, Input file: ${PVAL_FN}, Hitspec: ${HITSPEC}"

    echo "Plotting"
    LZ=/data/programs/bin/gwas/locuszoom/bin/locuszoom

    if [ "${LZ_SOURCE}" == "" ]
    then
        LZ_SOURCE="1000G_March2012"
    fi

    SAVEDIR=`pwd`
    cd $LZDIR    
    ${LZ}   --metal ${PVAL_FN} \
        --hitspec ${HITSPEC} \
        --pop EUR \
        --build hg19 \
        --source $LZ_SOURCE \
        --gwas-cat whole-cat_significant-only \
        --plotonly \
        metalRug=SNPs 2>&1 | tee ${LOG_DIR}/locuszoom-${FN}-${PHENO}-${ADJ}.log

    echo "Combine PDFs"
    PDFS=`ls *.pdf`
    PDF_FNS=""
    for PDF in $PDFS
    do
        PDF_FNS="${PDF_FNS}${PDF} 1 "
    done
    echo "Jam PDFs: ${PDF_FNS}"
    pdfjam -o ${FN}-${PHENO}-${ADJ}_LocusZoom.pdf ${PDF_FNS}

    cd $SAVEDIR
done
done
done
