ADJS="adjusted unadjusted"

for PHENO in ${PHENOTYPE_NAMES}
do


for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do

        echo "Add Pos: ${PHENO} ${GROUP} ${ADJ}"
        INFN="${DATA_DIR}/filtered/${PHENO}/gwama-${GROUP}-${ADJ}.out"
        OUTDIR="${DATA_DIR}/filtered-with-pos/${PHENO}"
        OUTFN="${OUT_DIR}/gwama-${GROUP}-${ADJ}.out"
        mkdir -p ${OUT_DIR}
        cat ${INFN} | perl ${SCRIPT_DIR}/add-pos.pl >> ${OUTFN} &

        ${SCRIPT_DIR}/wait-perl.sh

done
done
done

echo Waiting for last jobs
wait
