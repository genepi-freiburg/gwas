# params: in basename, out basename, over-chain-file (optional)
# needs basename.bed/bim/fam

SCRIPT_DIR=${0%/*}
LIFTOVER=/opt/hgLiftOver/liftOver
CHAIN=$3
if [ "${CHAIN}" == "" ]
then
	CHAIN=${SCRIPT_DIR}/hg18ToHg19.over.chain
fi

IN_BASENAME=$1
OUT_BASENAME=$2

IN_BIM=${IN_BASENAME}.bim
OUT_BIM=${OUT_BASENAME}.bim

IN_BED=${IN_BIM}.bed
OUT_BED=${OUT_BIM}.bed
UNMAPPED=${OUT_BIM}.unmapped

echo "Lift-over using chain ${CHAIN}"

# BIM to BED
${SCRIPT_DIR}/bimToBed.sh ${IN_BIM} ${IN_BED}

# Liftover
${LIFTOVER} ${IN_BED} ${CHAIN} ${OUT_BED} ${UNMAPPED}
rm -f ${IN_BED}

cat ${UNMAPPED} | awk '{ if (NF > 3) { print $4 } }' > ${UNMAPPED}.snps
UNMAPPED_SNPS=`wc -l ${UNMAPPED}.snps | awk '{print $1}'`
echo "There are ${UNMAPPED_SNPS} unmapped SNPs, see ${UNMAPPED}."

if [ ${UNMAPPED_SNPS} -gt 0 ]
then

	echo "These SNPs will be excluded."

	# exlude SNPs
	/usr/lib/plink/plink --noweb \
		--bfile ${IN_BASENAME} \
		--exclude ${UNMAPPED}.snps \
		--make-bed \
		--out ${OUT_BASENAME}
fi

# BED to BIM
${SCRIPT_DIR}/bedToBim.sh ${OUT_BED} ${OUT_BIM}.2
rm -f ${OUT_BED}

wc -l ${OUT_BIM} ${OUT_BIM}.2

echo "Overwrite with new map"
mv ${OUT_BIM}.2 ${OUT_BIM}

echo "Done."
