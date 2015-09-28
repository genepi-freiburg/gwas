IN_FN=$1
OUT_FN=$2
CHR=$3
zcat $IN_FN | awk -v chr="$CHR" '{ print chr, $1, 0, $2, $3, $4 }' | tail -n +2 > $OUT_FN

