ADJS="unadjusted adjusted"
OLD_DIR=`pwd`

for ADJ in ${ADJS}
do
	echo "Processing ${ADJ} data"
	mkdir -p ${DATA_DIR}/${ADJ}/qc
	cd ${DATA_DIR}/${ADJ}/qc
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

	xvfb-run Rscript ${SCRIPT_DIR}/04-gwasqc.R

	echo "Removing GWAS data links"
	rm *.gwas -v
done

cd ${OLD_DIR}

