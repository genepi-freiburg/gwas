# duplicates.txt file copy & paste from gwasqc() output
DUPLICATES=`cat duplicates.txt`
for DUP in ${DUPLICATES}
do
	echo -n ${DUP}
	POS=`grep ${DUP}\\\s adjusted/africans_ckid.gwas | cut -f 3`
	LC=`echo "${POS}" | wc -l`
	echo -n " lc ${LC}"
	
	LH=`echo "${POS}" | head -n 1`
	LT=`echo "${POS}" | tail -n 1`
	echo -n " lh ${LH} lt ${LT} "

	if [ "${LH}" -eq "${LT}" ]
	then
		echo "triallelic"
	else
		echo "pos mismatch"
	fi
done

