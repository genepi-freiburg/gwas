args <- commandArgs(trailingOnly = TRUE)
inputpathname = args[1]
outputpathname = args[2]
famname = args[3]

print("reading genome file")
data = read.table(paste(inputpathname, ".genome", sep=""), h=T)

pdf(paste(outputpathname, "/pairwise-IBD-histogram.pdf", sep=""))
hist(data$PI_HAT, col="RED", breaks=100, xlab="Estimated mean pairwise IBD", main="")
dev.off()

pdf(paste(outputpathname, "/pairwise-IBD-graph.pdf", sep=""))
plot(data$PI_HAT, xlab="Index", ylab="Proportion IBD")
abline(h=0.185,col="RED",lty=2)
dev.off()

out = which(data$PI_HAT > 0.185)
write.table(data[out,], file=paste(outputpathname, "/fail-IBD-check.txt", sep=""), col.names=T, row.names=F)

print("calculate avgDST")
dst = data
ind <- read.table(famname, header=F, stringsAsFactors=F)
ind$AvgDST <- NA
for (i in 1:nrow(ind)) {
    ind$AvgDST[i] <- mean(dst[dst$IID1==ind$V2[i] | dst$IID2==ind$V2[i], c("DST")])
}
ind<-ind[, c("V1","V2","AvgDST")]

pdf(paste(outputpathname, "/DST-plot.pdf", sep=""))
plot(density(dst$DST), main="All DST", xlab="DST")
rug(dst$DST)

plot(density(ind$AvgDST), main="Average DST", xlab="AvgDST")
rug(ind$AvgDST)
abline(v=0.678, col="blue")
abline(v=0.66, col="blue")
dev.off()

dst = data.frame(
	FID=ind$V1,
	IID=ind$V2,
	AVGDST=ind$AvgDST
)
write.table(dst, paste(outputpathname, "ind-dst.txt", sep="/"), col.names=T, row.names=F,quote=F)
