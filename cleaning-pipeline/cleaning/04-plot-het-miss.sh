#!/bin/bash
SD=2
MISS=0.03
IN="${RESULT_DIR}/${SOURCE_NAME}"
OUT="${RESULT_DIR}/imiss-vs-het-SD${SD}-M${MISS}.pdf"

if [ -f ${OUT} ]
then
	log "Skip plotting imiss-vs-het (already done)"
else
	log "Plot imiss-vs-het diagram, SD = ${SD}, MISS = ${MISS}"
	Rscript ${SCRIPT_DIR}/cleaning/04-imiss-vs-het.R ${IN} ${OUT} ${SD} ${MISS} 2>&1 >/dev/null
fi
