GWAS_FILE=$1
MAF=$2
HWE=$3
METAL_FILE=$4

cat ${GWAS_FILE} \
    | awk -v maf=$MAF -v hwe=$HWE 'BEGIN {
               OFS = "\t"
           };
           { 
               if (NR == 1) {
                   print "MarkerName", "P-value" 
               } else {
                   if ($10 >= maf && $10 <= 1-maf && $11 > hwe) {
                       if ($1 ~ /^rs.*:/) {
                           print substr($1, 1, index($1, ":")-1), $9 
                       } else {
                           print $1, $9 
                       }
                   }
               }
           }' > ${METAL_FILE}

