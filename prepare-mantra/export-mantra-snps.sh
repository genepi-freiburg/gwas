#!/bin/bash

DATFILE=${DATA_DIR}/mantra.dat
SNPFILE=${DATA_DIR}/all-snps-uniq.txt
SQLITEDB=${DATA_DIR}/gwas.sqlite
perl ${SCRIPT_DIR}/build-mantra-dat.pl ${DATFILE} ${SNPFILE} ${SQLITEDB} ${MIN_STUDIES}
