args = commandArgs(trailingOnly = TRUE)

infile = args[1]
scriptdir = args[2]
maf=as.numeric(args[3])
snpCol=args[4]
chrCol=args[5]
bpCol=args[6]
pvalCol=args[7]
mafCol=args[8]
outfn = args[9]

source(paste(scriptdir, "qqman.r", sep="/"))

print(paste("reading ", infile))
data = read.table(infile, h=T)

print("dimensions before MAF filter")
dim(data)

print("reformat")
data2 = data.frame(SNP=data[,snpCol], CHR=data[,chrCol],
                   BP=data[,bpCol], P=data[,pvalCol], MAF=data[,mafCol])
head(data2)
dim(data2)

data2 = subset(data2, data2$MAF >= maf & data2$MAF <= 1-maf)
print("dimensions after MAF filter")
dim(data2)

print(paste("make plot, output:", outfn))
png(outfn, width=2000, height=1000)
manhattan(data2)
dev.off()
print("finish")
