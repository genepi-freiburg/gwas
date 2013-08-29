cd output
FNS=`ls gwama-*-*adjusted.out -1`
cd ..

for FN in ${FNS}
do
	echo "Filter ${FN}"
	head -n 1 output/${FN} > filtered/${FN}
	cat output/${FN} | ./filter.pl >> filtered/${FN}
done
