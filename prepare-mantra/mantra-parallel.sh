#!/bin/bash

PART_COUNT=`ls -d ${DATA_DIR}/part* | wc -l`
echo "Found ${PART_COUNT} parts"

START_PART=$1
STOP_PART=$2

if [ "${START_PART}" == "" ]
then
	START_PART="0"
fi

if [ "${STOP_PART}" == "" ]
then
	STOP_PART=$(expr $PART_COUNT - 1)
fi

echo "Start with $START_PART, stop with $STOP_PART"

for partIdx in $(seq $START_PART $STOP_PART)
do
        if [[ ${partIdx} -lt 10 ]]
        then
                partIdx="0${partIdx}"
        fi
	echo "Start part ${partIdx}"
	cd ${DATA_DIR}/part${partIdx}
	${SCRIPT_DIR}/mantra.v1 < ${SCRIPT_DIR}/mantra-params.txt &
done

echo "Wait for subprocesses"
wait
