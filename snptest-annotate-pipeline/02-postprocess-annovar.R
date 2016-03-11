args = commandArgs(trailingOnly = TRUE)
infile = args[1]
outfile = args[2]
print(paste(infile, outfile))

data = read.table(infile, h=F, sep="", colClasses="character") 

colnames(data) = c(
        "FUNC",
	"GENES",
	"CHR",
        "START",
        "END",
        "REF",
        "OBS",
        "SNP",
        "BETA",
        "SE",
        "PVAL",
        "AF_OBS",
        "HWE_PVAL",
	"CASES_HWE_PVAL",
	"CONTROLS_HWE_PVAL",
        "CALLRATE",
        "N_TOTAL",
        "IMPUTED",
	"INFO"
)
summary(data)

write.table(data, outfile, row.names=F, col.names=T, quote=T, sep="\t")
