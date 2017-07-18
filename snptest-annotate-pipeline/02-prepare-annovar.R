args = commandArgs(trailingOnly = TRUE)
infile = args[1]
outfile = args[2]
print(paste(infile, outfile))

data = read.table(infile, h=T, colClasses="character") 
data$coded_all = as.character(data$coded_all)
data$noncoded_all = as.character(data$noncoded_all)

if (!("cases_hwe" %in% colnames(data))) {
	data$cases_hwe = NA
	data$controls_hwe = NA
}

out = data.frame(
	CHR=data$chr,
	START=data$position,
        END=as.numeric(data$position) + nchar(data$noncoded_all) - 1,
	REF=data$noncoded_all,
	OBS=data$coded_all,
	SNP=data$SNP,
	BETA=data$beta,
	SE=data$SE,
	PVAL=data$pval,
	AF_OBS=data$AF_coded_all,
	HWE_PVAL=data$HWE_pval,
	CASES_HWE_PVAL=data$cases_hwe,
	CONTROLS_HWE_PVAL=data$controls_hwe,
        CALLRATE=data$callrate,
	N_TOTAL=data$n_total,
	IMPUTED=data$imputed,
	INFO=data$oevar_imp
)

#write.table(out, outfile, row.names=F, col.names=T, quote=F)
write.table(out, outfile, row.names=F, col.names=F, quote=F)

