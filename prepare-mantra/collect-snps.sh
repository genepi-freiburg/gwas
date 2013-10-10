rm -f ${DATA_DIR}/mantra.in
rm -f ${DATA_DIR}/all-snps.txt
rm -f ${DATA_DIR}/all-snps-uniq.txt

for FILE in $FILES
do
	BASENAME=`basename ${FILE}`
	echo "Process $BASENAME" >> ${LOG_FILE}
	echo $BASENAME >> ${DATA_DIR}/mantra.in

	tail -n+2 $FILE | cut -f 1-5 >> ${DATA_DIR}/all-snps.txt
done

sort ${DATA_DIR}/all-snps.txt > ${DATA_DIR}/all-snps-sorted.txt
cat ${DATA_DIR}/all-snps-sorted.txt | uniq > ${DATA_DIR}/all-snps-uniq.txt
wc -l ${DATA_DIR}/*.txt >> ${LOG_FILE}

sort ${DATA_DIR}/mantra.in > /tmp/mantra.in
mv /tmp/mantra.in ${DATA_DIR}/mantra.in
