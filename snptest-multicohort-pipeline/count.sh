FNS=`find adjusted -name *.gwas`
for FN in $FNS
do
	echo "$FN 1E-5 1E-6" 
	cat $FN | cut -f 9 | awk '{ if ($1 < 1E-5) print }' | wc -l
	cat $FN | cut -f 9 | awk '{ if ($1 < 1E-6) print }' | wc -l
done
