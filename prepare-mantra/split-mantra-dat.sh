# Split File
split --lines=${LINE_COUNT} --numeric-suffixes --verbose ${DATA_DIR}/mantra.dat ${DATA_DIR}/mantra.dat.part
PART_COUNT=`ls ${DATA_DIR}/mantra.dat.part* | wc -l`
for partIdx in $(seq 0 $(expr $PART_COUNT - 1))
do
        if [[ ${partIdx} -lt 10 ]]
        then
                partIdx="0${partIdx}"
        fi
        mkdir -p ${DATA_DIR}/part${partIdx}
        mv ${DATA_DIR}/mantra.dat.part${partIdx} ${DATA_DIR}/part${partIdx}/mantra.dat
        cp ${DATA_DIR}/mantra.in ${DATA_DIR}/dmat.out ${DATA_DIR}/part${partIdx}/
done


