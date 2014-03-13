args <- commandArgs(trailingOnly = TRUE)

infn=args[1]
outfn=args[2]
data = read.table(infn)

binary = FALSE
if (!binary) {
  colnames(data) = c("FUNC", "GENES", "CHR", "START", "END", "REF", "OBS", "RSID",
                     "ALL1", "ALL2", "EAF", "BETA", "SE", "BETA_95L", "BETA_95U",
                     "Z", "PVAL", "LOG10PVAL", "QSTAT", "QPVAL", "I2", "N_STUD",
                     "N_SAMP", "EFFECTS")
} else {
  colnames(data) = c("FUNC", "GENES", "CHR", "START", "END", "REF", "OBS", "RSID",
                     "ALL1", "ALL2", "EAF", "OR", "OR_SE", "OR_95L", "OR_95U",
                     "Z", "PVAL", "LOG10PVAL", "QSTAT", "QPVAL", "I2", "N_STUD",
                     "N_SAMP", "EFFECTS")
}

data$Z = data$LOG10PVAL = data$QSTAT = data$QPVAL = data$ALL1 = data$ALL2 = NULL

# maf
maf_filter = 0.05 # filter rare variants

print("unfiltered: ")
print(nrow(data))
summary(data$EAF)
print(paste("passing MAF filter", length(which(data$EAF > maf_filter & data$EAF < (1-maf_filter)))))
data = data[data$EAF > maf_filter & data$EAF < (1-maf_filter),]
print(paste("MAF filter", maf_filter))
print(nrow(data))
summary(data$EAF)

# nstud
minstud = min(data$N_STUD)
maxstud = max(data$N_STUD)
medstud = median(data$N_STUD)
if (minstud < maxstud & medstud < maxstud) {
  print(paste("filter for N_STUD >", medstud))
  data = data[data$N_STUD > medstud,]
}

# sort
print("sort for CHR, POS")
data = data[order(data$CHR, data$START),]

write.table(data, outfn, row.names=F, col.names=T, quote=F, sep="\t")
