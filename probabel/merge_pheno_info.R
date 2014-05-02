args <- commandArgs(trailingOnly = TRUE)
inphenofn = args[1]
indosefn = args[2]
iidcol = args[3]
timecol = args[4]
eventcol = args[5]
outfn = args[6]
covarcols = args[7]  # omit for unadjusted analysis

print(paste("read phenotype", inphenofn))
pheno = read.table(inphenofn, h=T)
summary(pheno)

print(paste("read individuals from dose", indosefn))
#dose_cols = count.fields(indosefn, sep=" ")[1]
#print(paste("found", dose_cols-2, "SNPs"))
#info = read.table(indosefn, colClasses=c("string", rep("NULL", dose_cols-1)))
info = read.table(pipe(paste("cut -d ' ' -f1 '", indosefn, "'", sep="")))
colnames(info) = c("MLDOSE_IID")
info$IID = sapply(info$MLDOSE_IID, function(x) { unlist(strsplit(as.character(x), "->"))[2] })
info$IID = as.factor(info$IID)
info$IDX = 1:nrow(info)
summary(info)

print(paste("merge by columns IID /", iidcol))
merged = merge(info, pheno, all.x=T, by.x="IID", by.y=iidcol)

if (nrow(merged) != nrow(info)) {
	stop("phenotype length mismatch - check for duplicates in input file")
}

merged = merged[order(merged$IDX),]

final = data.frame(IID=merged$IID,
	SURV_TIME=merged[,timecol],
	EVENT=merged[,eventcol])

missing_iid_idx = which(is.na(final$SURV_TIME) | is.na(final$EVENT))
missing_iid = data.frame(IID=final[missing_iid_idx, "IID"])

print("missing EVENT / SURV_TIME")
head(missing_iid)
dim(missing_iid)

if (!is.na(covarcols)) {
	for (covar in unlist(strsplit(covarcols, ","))) {
		print(paste("add covar", covar))
		final = cbind(final, merged[,covar])
		colnames(final)[ncol(final)] = covar

		print(paste("missing covar", covar))
		missing_covar_idx = which(is.na(final[,covar]))
		missing_covar = data.frame(IID=final[missing_covar_idx,"IID"])
		print(head(missing_covar))
		print(nrow(missing_covar))

		missing_iid = rbind(missing_iid, missing_covar)
	}
} else {
	print("no covariates")
}

summary(final)
write.table(final, outfn, row.names=F, col.names=T, quote=F, sep=" ")

print("missing IID (non-unique)")
dim(missing_iid)
head(missing_iid)
missing_iid = unique(missing_iid)
print("missing IID (unique)")
dim(missing_iid)
head(missing_iid)

print("non-missing IID")
non_missing_iid = final[which(!(final$IID %in% missing_iid$IID)), "IID"]
dim(non_missing_iid)
head(non_missing_iid)

write.table(missing_iid, paste(outfn, ".missing", sep=""), row.names=F, col.names=F, quote=F)
write.table(non_missing_iid, paste(outfn, ".keep", sep=""), row.names=F, col.names=F, quote=F)

