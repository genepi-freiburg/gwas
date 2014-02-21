IN_BIM=$1
IN_BED=$2

cat ${IN_BIM} | awk \
        '{
                printf "chr"
                if ($1 == 23) {
                        printf "X"
                } else if ($1 == 24) {
                        printf "Y"
                } else if ($1 == 25) {
                        printf "X_nonPAR"
                } else {
                        printf $1
                }
                print "\t" $4 - length($5) "\t" $4 "\t" $2 "\t" $5 "\t" $6
        }' \
        >${IN_BED}

