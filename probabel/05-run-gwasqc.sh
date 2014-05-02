GWAS_OUT_DIR=${DATA_DIR}/gwasqc
GWASQC_OUT_DIR=${GWAS_OUT_DIR}/qc
mkdir -p ${GWASQC_OUT_DIR}	

cd ${GWASQC_OUT_DIR}
rm -vf *.gwas *.html *.png *.csv *.txt
echo "Linking GWAS result data"
ln -s ../*.gwas . -v
ls -l *.gwas
	
cat ${SCRIPT_DIR}/gwasqc.in.txt > gwasqc.in.txt
for FN in ${COHORTS}
do
	echo "PROCESS ${FN}.gwas" >> gwasqc.in.txt
done

# wait for previous xvfb to die
sleep 3
xvfb-run Rscript ${SCRIPT_DIR}/gwasqc.R

echo "Removing GWAS data links"
rm *.gwas -v
