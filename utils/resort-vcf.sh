   INFN=$1
   OUTFN=$2
   
   if [ ! -f "$INFN" ]
   then
           echo "Input file does not exist: $INFN"
           exit
   fi
   
   if [ -f "$OUTFN" ]
   then
           echo "Output file must not exist: $OUTFN"
           exit
   fi
   
   echo "Sort VCF: $INFN"
   (zgrep ^"#" $INFN ; zgrep -v ^"#" $INFN | sort -k2n) | bgzip > $OUTFN
   
   echo "Index VCF: $OUTFN"
   tabix -p vcf $OUTFN
   
   echo "Done"
