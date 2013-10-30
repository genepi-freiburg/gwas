

rm ${DATA_DIR}/mantra.out
PARTS=`ls ${DATA_DIR}/part* -d`
echo $PARTS
for PART in ${PARTS}
do
echo "Add ${PART}"
cat ${PART}/mantra.out >> ${DATA_DIR}/mantra.out
done

echo Sorting by log10 Bayes factor
sort ${DATA_DIR}/mantra.out -k 7 -n -r > ${DATA_DIR}/mmantra.out.sorted
