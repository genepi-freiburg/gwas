ADJS="unadjusted adjusted"
for ADJ in ${ADJS}
do
	echo "Processing ${ADJ} data"
	mkdir -p ${ADJ}/qc
	cd ${ADJ}/qc
	rm -vf *.gwas *.html *.png *.csv *.txt
	echo "Linking GWAS result data"
	ln -s ../*.gwas . -v
	ls -l *.gwas
	xvfb-run Rscript ../../05-gwasqc.R
	echo "Removing GWAS data links"
	rm *.gwas -v
	cd ../..
done

