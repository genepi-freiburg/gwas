args = commandArgs(trailingOnly = TRUE)
infile = args[1]
scriptdir = args[2]
outfn = args[3]
maf = as.numeric(args[4])

print(infile)

source(paste(scriptdir, "qqman.r", sep="/"))

data = read.table(infile, h=T)
print("read table")
dim(data)
# SNP     chr     position        coded_all       noncoded_all    strand_genome   beta    SE      pval    AF_coded_all    HWE_pval      callrate n_total imputed used_for_imp    oevar_imp

print("reformat")
data2 = data.frame(SNP=data$SNP, CHR=data$chr, BP=data$position, P=data$pval, EAF=data$AF_coded_all)
head(data2)
rm(data)

print(paste("MAF filter", maf))
print(nrow(data2))
data2 = data2[which(data2$EAF >= maf & data2$EAF <= 1-maf),]
print(nrow(data2))

print(paste("make plot", outfn))
png(outfn, width=2400, height=1400)
manhattan(data2)
dev.off()
