
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
		temp<-data[data$chr == chr,]
		ichr = which(data$chr == chr)
		#print(ichr)
		top_i = 1
		top_p = temp$Pfkt[1]
		top_chr=temp$chr[1]
		top_pos=temp$pos[1]
		
		data$Indep1MB[ichr[1]]="independent"
		
		if(length(temp[,1])>1) {
			for(i in 2:length(temp[,1])) {
				dpos = temp$pos[i] - top_pos
				p = temp$Pfkt[i]
                
				#print(dpos)
				#print(p)
				#print(temp$pos[i])
				
				if(dpos < 1e6 & p > top_p ) {
					data$Indep1MB[ichr[i]]="NA"
					data$Indep1MB[ichr[top_i]]="independent"
				}
				if(dpos < 1e6 & p <= top_p ) {
					data$Indep1MB[ichr[i]]="independent"
					data$Indep1MB[ichr[top_i]]="NA"
					top_i = i
					top_p = temp$Pfkt[i]
					top_chr=temp$chr[i]
					top_pos=temp$pos[i]
				}
				if(dpos >= 1e6) {
					data$Indep1MB[ichr[i]]="independent"
					top_i = i
					top_p = temp$Pfkt[i]
					top_chr=temp$chr[i]
					top_pos=temp$pos[i]
				}
			}
		}
		if(length(temp[,1])==1) {
			data$Indep1MB[ichr[1]]="independent"
		}


	}
	
	names(data)[names(data)=="Pfkt"] <- Column.names[1]
	names(data)[names(data)=="chr"] <- Column.names[2]
	names(data)[names(data)=="pos"] <- Column.names[3]
	
	
	#return(data)
	print("Writing new table...")
	write.table(data,outputfile,row.names=F,quote=F,col.names = TRUE,sep="\t")
	print("All ok.")
}

