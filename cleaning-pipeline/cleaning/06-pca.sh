#!/bin/bash

log "extract HapMap SNPs"

${PLINK} \
        --noweb \
        --bfile ${SOURCE_NOF_FILE} \
        --extract ${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.no-at-cg-snps.txt \
        --make-bed \
        --out ${TEMP_DIR}/01-extract-hapmap-snps \
		2>&1 >/dev/null

log "identify SNPs in high-LD regions for exclusion; prune SNPs by LD"

${PLINK} --noweb \
       --bfile ${TEMP_DIR}/01-extract-hapmap-snps \
	--exclude ${SCRIPT_DIR}/aux/high-LD-regions.txt \
	--range --indep-pairwise 50 5 0.2 \
	--out ${TEMP_DIR}/02-high-ld \
		2>&1 >/dev/null

log "merge HapMap - phase 1"

${PLINK} \
	--noweb \
	--bfile ${TEMP_DIR}/01-extract-hapmap-snps \
	--bmerge ${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.founders.no-at-cg-snps.bed \
		${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.founders.no-at-cg-snps.bim \
		${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.founders.no-at-cg-snps.fam \
	--extract ${TEMP_DIR}/02-high-ld.prune.in \
	--make-bed \
	--out ${TEMP_DIR}/03-merge-hapmap \
		2>&1 >/dev/null

if [ -f ${TEMP_DIR}/03-merge-hapmap.missnp ]
then

	log "merge HapMap - flip SNPs"

	${PLINK} \
	--noweb \
	--bfile ${TEMP_DIR}/01-extract-hapmap-snps \
       --extract ${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.no-at-cg-snps.txt \
       --flip ${TEMP_DIR}/03-merge-hapmap.missnp \
       --make-bed \
       --out ${TEMP_DIR}/04-extract-hapmap-flip-snps \
		2>&1 >/dev/null

	mv ${TEMP_DIR}/04-extract-hapmap-flip-snps.log ${LOG_DIR}/hapmap-flip.log

	log "merge HapMap - phase 2"

	${PLINK} \
	--noweb \
	--bfile ${TEMP_DIR}/04-extract-hapmap-flip-snps \
	--bmerge ${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.founders.no-at-cg-snps.bed \
		${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.founders.no-at-cg-snps.bim \
		${SCRIPT_DIR}/aux/hapmap3r2_CEU.CHB.JPT.YRI.founders.no-at-cg-snps.fam \
	--extract ${TEMP_DIR}/02-high-ld.prune.in \
	--make-bed \
	--out ${TEMP_DIR}/05-merge-hapmap

	mv ${TEMP_DIR}/05-merge-hapmap.log ${LOG_DIR}/hapmap-merge.log

	if [ -f ${TEMP_DIR}/05-merge-hapmap.missnp ]
	then
		log "WARNING: corrupt SNPs, unable to flip"
	fi

else

	log "no need to flip SNPs"
	mv ${TEMP_DIR}/03-merge-hapmap.log ${LOG_DIR}/hapmap-merge.log

	ln -s ${TEMP_DIR}/03-merge-hapmap.bed ${TEMP_DIR}/05-merge-hapmap.bed
	ln -s ${TEMP_DIR}/03-merge-hapmap.bim ${TEMP_DIR}/05-merge-hapmap.bim
	ln -s ${TEMP_DIR}/03-merge-hapmap.fam ${TEMP_DIR}/05-merge-hapmap.fam

fi

log "convert BED/BIM/FAM to PED/MAP"

${PLINK} \
	--noweb \
	--bfile ${TEMP_DIR}/05-merge-hapmap \
	--recode \
       --output-missing-phenotype 1 \
       --out ${TEMP_DIR}/06-merge-hapmap \
		2>&1 >/dev/null

log "convert PED/MAP to SNP/IND"

cat ${SCRIPT_DIR}/aux/convertf.par.template | sed "s|TEMP_DIR|${TEMP_DIR}|g" > ${TEMP_DIR}/07-convertf.par
${CONVERTF} -p ${TEMP_DIR}/07-convertf.par 2>&1 >/dev/null

log "conduct PCA"

cat ${SCRIPT_DIR}/aux/smartpca.par.template | sed "s|TEMP_DIR|${TEMP_DIR}|g" > ${TEMP_DIR}/08-smartpca.par
${SMARTPCA} -p ${TEMP_DIR}/08-smartpca.par 2>&1 > ${TEMP_DIR}/08-smartpca.stdout.stderr
cp ${TEMP_DIR}/08-merge-hapmap.evec ${RESULT_DIR}/${SOURCE_NAME}.evec
cp ${TEMP_DIR}/08-merge-hapmap.eval ${RESULT_DIR}/${SOURCE_NAME}.eval
cp ${TEMP_DIR}/08-merge-hapmap.outlier ${RESULT_DIR}/${SOURCE_NAME}.outlier

log "plot PCA result"

Rscript ${SCRIPT_DIR}/cleaning/06-plot-pca-results.R ${TEMP_DIR}/08-merge-hapmap.evec ${RESULT_DIR}/pca-plot.pdf 2>&1 >/dev/null

#rm -f ${TEMP_DIR}/*
