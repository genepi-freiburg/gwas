
fkt.get.indpendent.SNPs <- function(myinputpath,myoutputpath,myinputfile,myoutputfile,Column.names)
{
	inputfile<-paste(myinputpath,myinputfile,sep="")
	outputfile<-paste(myoutputpath,myoutputfile,sep="")

	# merges position-data (chr, pos) to results-data
	# Column.names: (p chr pos)
	data<-read.table(inputfile,header=T,sep="")
	
	names(data)[names(data)==Column.names[1]] <- "Pfkt"
	names(data)[names(data)==Column.names[2]] <- "chr"
	names(data)[names(data)==Column.names[3]] <- "pos"

	
	#print(data[1:3,])

	data<-data[order(data$chr,data$pos),]

	data<-cbind(data,"Indep1MB"=as.character(rep("NA",length(data[,1]))))

	data$Indep1MB=as.character(data$Indep1MB)

	#print(data[1:3,])

	chrList<-sort(unique(data$chr))

	#print(chrList)

	for(chr in chrList) {
		ichr = which(data$chr == chr)
		while(any(data$Indep1MB[ichr] == "NA")){
			top_i = which.min(data$Pfkt[ichr][data$Indep1MB[ichr] == "NA"])
			top_p = data$Pfkt[ichr][data$Indep1MB[ichr] == "NA"][top_i]
			top_chr=data$chr[ichr][data$Indep1MB[ichr] == "NA"][top_i]
			top_pos=data$pos[ichr][data$Indep1MB[ichr] == "NA"][top_i]
			
			data$Indep1MB[ichr][data$Indep1MB[ichr] == "NA"][top_i] <- "independent"
	
			dpos <- abs(data$pos-top_pos)
			index <- data$chr == top_chr & dpos<500000 & data$Indep1MB == "NA"
			if(sum(index)>0){
				data$Indep1MB[index] <- "dependent"
			}
			rm(dpos,index)
		}
	}	
	
	data$Indep1MB[data$Indep1MB == "dependent"] <- "NA"
	
	names(data)[names(data)=="Pfkt"] <- Column.names[1]
	names(data)[names(data)=="chr"] <- Column.names[2]
	names(data)[names(data)=="pos"] <- Column.names[3]
	
	
	#return(data)
	print("Writing new table...")
	write.table(data,outputfile,row.names=F,quote=F,col.names = TRUE,sep="\t")
	print("All ok.")
}

