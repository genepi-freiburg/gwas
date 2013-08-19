RSIDS="rs12039194 rs1549343 rs1447826 rs1455311 rs361147 rs9272729 rs1036819 rs1975920 rs7137203 rs4943552 rs2221705 rs2236479 rs17830558 rs56089820"
echo -e "CHR\tPOS_1\tRSID_1\tPOS_2\tRSID_2\tR2\tDIST" >proxies.txt
for RSID in ${RSIDS}
do
	echo "Find 3 proxies for ${RSID}"
	./select-proxies.sh ${RSID} 2>/dev/null | head -n 5 | tail -n+3 >>proxies.txt
done
echo "Output written to 'proxies.txt'"
