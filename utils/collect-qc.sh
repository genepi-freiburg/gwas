mkdir qc
. pipeline-params
for PHENO in ${PHENOTYPE_NAMES}
do
	echo "Collect $PHENO"
	cp -r out/${PHENO}/adjusted/qc qc/${PHENO}
done
zip -r qc.zip qc
rm -rf qc
