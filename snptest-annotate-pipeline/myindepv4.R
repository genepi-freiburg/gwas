args = commandArgs(trailingOnly = TRUE)

print(paste("in", args[1], "out", args[2], "script", args[3]))

source(paste(args[3], "indep1MBv4.r", sep="/"))

fkt.get.indpendent.SNPs(args[1], args[2], "", "", c("pval","chr","position"))

data = read.table(args[2], h=T, stringsAsFactors=F)
nrow(data)
data = subset(data, data$pval < 1e-5)
print("filter p<1e-5")
nrow(data)
data = subset(data, data$Indep1MB=="independent")
print("filter indep")
nrow(data)
write.table(data, args[2], row.names=F, col.names=T, quote=F)

lzin = data.frame(snp=as.character(data$SNP), chr="NA", start="NA", stop="NA", flank="1mb",run="yes",m2zargs="", stringsAsFactors=F)
#lzin$snp = ifelse(strpos(lzin$snp, ":")>-1, substr(lzin$snp,1,strpos(lzin$snp,":")), lzin$snp)
#lzin$snp = strsplit(lzin$snp,":")[1]
for (i in 1:nrow(lzin)) {
 prev=lzin[i,"snp"]
 news=unlist(strsplit(as.character(lzin[i,"snp"]),":"))
 onlysnp=news[1]
 print(onlysnp)
 lzin[i,"snp"] = as.character(onlysnp)
}
write.table(lzin, paste(args[2],".hitspec_snps",sep=""), row.names=F, col.names=T, quote=F, sep="\t")

lzin = data.frame(snp=as.character(data$SNP), chr="NA", start="NA", stop="NA", flank="NA",run="yes",m2zargs="", stringsAsFactors=F)
for (i in 1:nrow(lzin)) {
	lzin[i,"snp"] = NA
	lzin[i,"chr"] = data[i, "chr"]
	lzin[i,"start"] = data[i, "position"]-500000
	lzin[i,"stop"] = data[i, "position"]+500000
	if (lzin[i,"start"]<0) {
		lzin[i,"start"] = 0
	}
}
write.table(lzin, paste(args[2],".hitspec",sep=""), row.names=F, col.names=T, quote=F, sep="\t")

#snp chr start stop flank run m2zargs
#rs2070741 NA NA NA 500kb yes

warnings()
