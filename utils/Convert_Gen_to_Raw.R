args <- commandArgs(trailingOnly = TRUE)
gen_fn = args[1]
fam_fn = args[2]
out_fn = args[3]

print(paste("Convert", gen_fn, "to", out_fn, "using FAM", fam_fn))

gen = read.table(gen_fn, h=F)
print(paste("GEN file rows: ", nrow(gen), "; cols: ", ncol(gen), sep=""))

fam = read.table(fam_fn, h=F)
print(paste("FAM file rows: ", nrow(fam), "; cols: ", ncol(fam), sep=""))

COL_HEADER_LENGTH=5
colnames(gen)[1:COL_HEADER_LENGTH] = c("rsid","snpid","pos","all_a","all_b")
if (ncol(gen) - COL_HEADER_LENGTH != nrow(fam) * 3) {
	print(paste("ERROR: GEN/FAM mismatch! GEN columns", ncol(gen) - COL_HEADER_LENGTH, "and FAM rows", nrow(fam) * 3))
	stop(99)
}

result = gen[,1:COL_HEADER_LENGTH]

print("Calculate dosages")
for (i in 1:nrow(fam)) {
	iid=fam[i,2]
	result[,COL_HEADER_LENGTH+i] = gen[,COL_HEADER_LENGTH+(i-1)*3+2] + 2 * gen[,COL_HEADER_LENGTH+(i-1)*3+3]
	colnames(result)[i+COL_HEADER_LENGTH] = paste(iid, "", sep="")
}

print("Transpose dataset")
result_t = t(result[,(COL_HEADER_LENGTH+1):ncol(result)])
colnames(result_t) = paste(result[,2], result[,4], sep="_")
final = cbind(row.names(result_t), result_t)
colnames(final)[1] = "IID"
write.table(final, out_fn, col.names=T, row.names=F, quote=F)
