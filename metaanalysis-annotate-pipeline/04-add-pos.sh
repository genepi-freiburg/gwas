cd filtered
for FN in $(ls -1)
do
	echo ${FN}
	cat ${FN} | perl ../add-pos.pl > ../filtered-with-pos/${FN} &
done
cd ..

echo Waiting
wait
