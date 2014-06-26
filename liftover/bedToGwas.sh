IN_BIM=$2
IN_BED=$1


awk 'NR==FNR{ a[$1] = $2 "\t" $3"\t" $4 "\t" $5 "\t" $6;next} {$5 = a[$4]; print }' OFS='\t' ${IN_BED} ${IN_BIM}   >out


#awk \
#	'NR==FNR{
#		a[$1] = $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6;next
#	} {
#		$5 = a[$4]; print
#	}' OFS='\t'\
#	
#	${IN_BED} ${IN_BIM} >test.out


#erst csv dann bed




#cat ${IN_BIM} | awk \
#        '{
#                printf "chr"
#                if ($1 == 23) {
#                        printf "X"
#                } else if ($1 == 24) {
#                        printf "Y"
#                } else if ($1 == 25) {
#                        printf "X_nonPAR"
#                } else {
#                        printf $1
#                }
#                print "\t" $4 - length($5) "\t" $4 "\t" $2 "\t" $5 "\t" $6
#        }' \
#        >${IN_BED}

