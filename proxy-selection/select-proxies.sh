ORIGINAL_SNP=${1}
WORKING_DIR=${2}
if [ "${WORKING_DIR}" == "" ]
then
	WORKING_DIR=/tmp/proxysnps
fi

if [ "${ORIGINAL_SNP}" == "" ]
then
	echo "Usage: ${0} snpid [working_dir]"
	exit 9
fi

rm -f ${WORKING_DIR}/proxy-snps.*

POP=EUR
KGP_DATA=/data/gwas/1kgp/merge/${POP}/1kgp-${POP}
WINDOW_SIZE=250
PLINK=/usr/lib/plink/plink

echo -n "Determine chromosome for ${ORIGINAL_SNP}: " >&2
CHR=`grep "\\s${ORIGINAL_SNP}\\s" ${KGP_DATA}.bim | cut -f 1`
echo "${ORIGINAL_SNP} is on chromosome ${CHR}." >&2

echo "Searching for proxies for ${ORIGINAL_SNP} (window size ${WINDOW_SIZE} kb)" >&2
mkdir -p ${WORKING_DIR}
echo "Using working directory ${WORKING_DIR}" >&2
cd ${WORKING_DIR}

KGP_CHR_DATA="/data/gwas/1kgp/final/${POP}/1kgp-${POP}-chr${CHR}"

${PLINK} --noweb \
	--bfile ${KGP_CHR_DATA} \
	--r2 \
	--ld-window-kb ${WINDOW_SIZE} \
	--ld-window-r2 0.2 \
	--ld-window 999999 \
	--ld-snp ${ORIGINAL_SNP} \
	--filter-founders \
	--out ${WORKING_DIR}/proxy-snps >&2

# sortieren und ausgeben
echo -e "CHR\tPOS_1\tRSID_1\tPOS_2\tRSID_2\tR2\tDIST"
tail -n+2 ${WORKING_DIR}/proxy-snps.ld | awk \
	'function abs(x) { return ((x < 0.0) ? -x : x) } 
         { print $1 "\t" $2 "\t" $3 "\t" $5 "\t" $6 "\t" $7 "\t" abs($5-$2) }' \
	| sort -k6,6rn -k7,7n | head -n 20
