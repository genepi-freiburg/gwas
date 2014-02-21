OUT_BED=$1
OUT_BIM=$2

cat ${OUT_BED} | awk \
        '{ 
		CHR=substr($1, 4)
		if (CHR == "X") {
			CHR=23
		} else if (CHR == "Y") {
			CHR=24
		} else if (CHR == "X_nonPAR") {
			CHR=25
		}
		print CHR "\t" $4 "\t0\t" $3 "\t" $5 "\t" $6 
	 }' \
        >${OUT_BIM}

