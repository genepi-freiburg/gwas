library(Rmpfr)

	.N <- function(.) mpfr(., precBits = 200)

	as.numeric.rmpfr <- function(x){
		parts <- as.numeric(strsplit(split="e",x)[[1]])
		if(length(parts)==1){return(as.numeric(x))}else if(parts[2]> -300){return(as.numeric(x))} else {
			x <- parts[1]*.N(10)^parts[2]
			return(x)
		}
	}
	
	which.min.rmpfr <- function(lst){
		top <- 1
		while(is.na(lst[top])){top <- top+1}
		if(top > length(lst)){return(NA)}
		if(top == length(lst)){return(top)}
		for(i in (top+1):length(lst)){
			if(!is.na(lst[i])){
				if(lst[[i]] == pmin(lst[[top]],lst[[i]])){
					top <- i
				}
			}
		}
		return(top)
	}

fkt.get.indpendent.SNPs <- function(myinputpath,myoutputpath,myinputfile,myoutputfile,Column.names)
{
	inputfile<-paste(myinputpath,myinputfile,sep="")
	outputfile<-paste(myoutputpath,myoutputfile,sep="")

	# merges position-data (chr, pos) to results-data
	# Column.names: (p chr pos)
# 	data<-read.table(inputfile,header=T,sep="")
	data<-read.table(inputfile,header=T,sep="",colClasses = "character")
# 	data <- data[1:10,]	
	
	names(data)[names(data)==Column.names[1]] <- "Pfkt"
	names(data)[names(data)==Column.names[2]] <- "chr"
	names(data)[names(data)==Column.names[3]] <- "pos"

	
	#print(data[1:3,])
	data$chr <- as.numeric(data$chr)
	data$pos <- as.numeric(data$pos)
	data<-data[order(data$chr,data$pos),]

	data<-cbind(data,"Indep1MB"=as.character(rep("NA",length(data[,1]))))

	data$Indep1MB=as.character(data$Indep1MB)

	#print(data[1:3,])

	chrList<-sort(unique(data$chr))

	#print(chrList)

	pval_rmpfr <- lapply(data$Pfkt,as.numeric.rmpfr)

	for(chr in chrList) {
		ichr = which(data$chr == chr)
		while(any(data$Indep1MB[ichr] == "NA")){
			top_i = which.min.rmpfr(pval_rmpfr[ichr][data$Indep1MB[ichr] == "NA"])
# 			top_p = data$Pfkt[ichr][data$Indep1MB[ichr] == "NA"][top_i]
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

