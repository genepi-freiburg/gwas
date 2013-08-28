FNS="africans_ckid turks_4c whites_4c whites_escape turks_escape whites_ckid"
ADJS="adjusted unadjusted"
CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"

for FN in ${FNS}
do
for ADJ in ${ADJS}
do
for CHR in ${CHRS}
do
	echo Format ${FN} ${CHR} ${ADJ}
	./formatting.pl -i ${ADJ}/${FN}-chr${CHR}.out -c ${CHR} -o ${ADJ}/${FN}-chr${CHR}.gwas &
	./wait-perl.sh
done
done
done

echo "Waiting for remaining formatting jobs"
wait

for FN in ${FNS}
do
for ADJ in ${ADJS}
do

echo "Combine ${FN} ${ADJ}"
cat ${ADJ}/${FN}-chr1.gwas >${ADJ}/${FN}.gwas
CHRS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
for CHR in ${CHRS}
do
	sed -e '1d' ${ADJ}/${FN}-chr${CHR}.gwas >>${ADJ}/${FN}.gwas
done
rm ${ADJ}/${FN}-chr*.gwas

done
done
