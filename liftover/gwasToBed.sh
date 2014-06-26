OUT_BED=$1
OUT_BIM=$2

cat ${OUT_BED} | awk \
        ' NR>1 { 
		CHR=$7
		if (CHR == "X") {
			CHR=23
		} else if (CHR == "Y") {
			CHR=24
		} else if (CHR == "X_nonPAR") {
			CHR=25
		} 
		print "chr"CHR "\t" $8 "\t" $8+1 "\t" $1
	 }' \
        >${OUT_BIM}

