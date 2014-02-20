determine_fail_het = function(het, sd) {
  sdMeanHet = sd(het$meanHet)
  meanMeanHet = mean(het$meanHet)
  b1 = meanMeanHet+sd*sdMeanHet
  b2 = meanMeanHet-sd*sdMeanHet
  outliers = which(het$meanHet > b1 | het$meanHet < b2)
  return(data.frame(IID=het[outliers, "IID"]))
}

args <- commandArgs(trailingOnly = TRUE)
result_dir = args[1]
file_name = args[2]
e1l = as.numeric(args[3])
e1u = as.numeric(args[4])
e2l = as.numeric(args[5])
e2u = as.numeric(args[6])
dstl = as.numeric(args[7])
dstu = as.numeric(args[8])

fail_sex = read.table(paste(result_dir, "/fail-sexcheck.txt", sep=""), col.names="IID")
fail_miss = read.table(paste(result_dir, "/fail-missingness.txt", sep=""), col.names="IID")

avgdst = read.table(paste(result_dir, "/ind-dst.txt", sep=""), h=T)
fail_dst = avgdst[which(avgdst$AVGDST < dstl | avgdst$AVGDST > dstu),]
fail_dst = data.frame(IID=fail_dst$IID)
summary(fail_dst)

print(paste("failing AvgDST", nrow(fail_dst)))
print(paste("passing AvgDST", nrow(avgdst) - nrow(fail_dst)))

fail_pca_8sd = read.table(paste(result_dir, "/fail-pca-outlier_8sd.txt", sep=""), h=F, col.names="IID")

het = read.table(paste(result_dir, "/", file_name, ".het", sep=""), h=T)
het$meanHet = (het$N.NM. - het$O.HOM.) / het$N.NM.

fail_het2 = determine_fail_het(het, 2)
fail_het3 = determine_fail_het(het, 3)
fail_het4 = determine_fail_het(het, 4)
fail_het5 = determine_fail_het(het, 5)
fail_het6 = determine_fail_het(het, 6)

fail_ibd = read.table(paste(result_dir, "/fail-IBD-QC.txt", sep=""), col.names=c("FID", "IID"))
fail_ibd$FID = NULL

evec = read.table(paste(result_dir, "/", file_name, ".evec", sep=""))
colnames(evec)=c("IID","E1","E2","E3","E4","E5","E6","E7","E8","E9","E10","GROUP")
evec = subset(evec, evec$GROUP == "Case" | evec$GROUP == "Control")
failing_evec = evec[evec$E1 < e1l | evec$E1 > e1u | evec$E2 < e2l | evec$E2 > e2u,]
fail_pca = data.frame(IID=failing_evec$IID)

print(paste("failing PCA", nrow(fail_pca)))
print(paste("passing PCA", nrow(evec)-nrow(fail_pca)))

# merge
fail_any = merge(fail_sex, fail_miss, all=T)
fail_any = merge(fail_any, fail_het2, all=T)
fail_any = merge(fail_any, fail_het3, all=T)
fail_any = merge(fail_any, fail_het4, all=T)
fail_any = merge(fail_any, fail_het5, all=T)
fail_any = merge(fail_any, fail_het6, all=T)
fail_any = merge(fail_any, fail_ibd,  all=T)
fail_any = merge(fail_any, fail_pca,  all=T)
fail_any = merge(fail_any, fail_pca_8sd,  all=T)
fail_any = merge(fail_any, fail_dst,  all=T)

fail_any$fail_miss  = fail_any$IID %in% fail_miss$IID
fail_any$fail_sex  = fail_any$IID %in% fail_sex$IID
fail_any$fail_het2 = fail_any$IID %in% fail_het2$IID
fail_any$fail_het3 = fail_any$IID %in% fail_het3$IID
fail_any$fail_het4 = fail_any$IID %in% fail_het4$IID
fail_any$fail_het5 = fail_any$IID %in% fail_het5$IID
fail_any$fail_het6 = fail_any$IID %in% fail_het6$IID
fail_any$fail_ibd  = fail_any$IID %in% fail_ibd$IID
fail_any$fail_pca  = fail_any$IID %in% fail_pca$IID
fail_any$fail_pca_8sd  = fail_any$IID %in% fail_pca_8sd$IID
fail_any$fail_dst  = fail_any$IID %in% fail_dst$IID

fam = read.table(paste(result_dir, "/../", file_name, ".fam", sep=""), colClasses=c("character", "character", "character", "character", "factor", "character"))
colnames(fam) = c("FID", "IID", "P1", "P2", "SEX", "X")
fam$P1 = NULL
fam$P2 = NULL
fam$X = NULL
fail_fam = merge(fam, fail_any)

write.table(fail_fam, paste(result_dir, "/fail-table.csv", sep=""), row.names=F, col.names=T, quote=T, sep=";")
