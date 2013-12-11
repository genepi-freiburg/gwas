args = commandArgs(trailingOnly = TRUE)
infile = args[1]
outfile = args[2]
print(paste(infile, outfile))

data = read.table(infile, h=T)
data$coded_all = as.character(data$coded_all)
data$noncoded_all = as.character(data$noncoded_all)

out = data.frame(
	CHR=data$chr,
	START=data$position,
	END=data$position + nchar(data$noncoded_all) - 1,
	REF=data$noncoded_all,
	OBS=data$coded_all,
	SNP=data$SNP,
	BETA=data$beta,
	SE=data$SE,
	PVAL=data$pval,
	AF_OBS=data$AF_coded_all,
	HWE_PVAL=data$HWE_pval,
        CALLRATE=data$callrate,
	N_TOTAL=data$n_total,
	IMPUTED=data$imputed
)

#write.table(out, outfile, row.names=F, col.names=T, quote=F)
write.table(out, outfile, row.names=F, col.names=F, quote=F)

