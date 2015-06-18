ADJS="unadjusted adjusted"
OLD_DIR=`pwd`

if [ "${SKIP_UNADJUSTED_ANALYSIS}" == "1" ]
then
        ADJS="adjusted"
fi

for PHEN in ${PHENOTYPE_NAMES}
do
for ADJ in ${ADJS}
do
	echo "Processing ${PHEN} ${ADJ} data"
	mkdir -p ${DATA_DIR}/${PHEN}/${ADJ}/qc
	cd ${DATA_DIR}/${PHEN}/${ADJ}/qc
	rm -vf *.gwas *.html *.png *.csv *.txt
	echo "Linking GWAS result data"
	ln -s ../*.gwas . -v
	ls -l *.gwas
	
	# prepare input file
	cat ${SCRIPT_DIR}/04-gwasqc.in.txt > gwasqc.in.txt
	for FN in ${COHORTS}
	do
		echo "PROCESS ${FN}.gwas" >> gwasqc.in.txt
	done

	# wait for previous xvfb to die
	sleep 3
	xvfb-run -a Rscript ${SCRIPT_DIR}/04-gwasqc.R

	echo "Removing GWAS data links"
	rm *.gwas -v
done
done

cd ${OLD_DIR}

