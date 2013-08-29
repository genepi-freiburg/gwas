#!/bin/bash
ANNOVAR=/opt/annovar

cd filtered-with-pos
FNS=`ls -1`
I=0
cd ..

for FN in ${FNS}
do

cat filtered-with-pos/${FN} | tail -n+2 > annovar/${FN}
INFILE=annovar/${FN}

I=$[I+1]
echo Result file ${I}

PROTOCOLS=refGene,phastConsElements46way,genomicSuperDups,gwasCatalog,snp137,ljb2_all
OPERATION=g,r,r,r,f,f
#	-csvout \

${ANNOVAR}/table_annovar.pl ${INFILE} ${ANNOVAR}/humandb/ \
	-buildver hg19 \
	-protocol ${PROTOCOLS} \
	-operation ${OPERATION} \
	2>&1 | tee annovar/${FN}.annovar.in.stdout.txt &

if [ $I -gt 10 ] 
then
	echo "Wait"
	wait
	I=0
fi

done

wait
echo Wait for finish
