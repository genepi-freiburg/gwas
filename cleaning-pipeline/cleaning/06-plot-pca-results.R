args <- commandArgs(trailingOnly = TRUE)
evecname = args[1]
pdfname = args[2]

data = read.table(evecname, h=F, skip=1)
cont = which(data$V12=="Control" | data$V12=="Case")
CEU = which(data$V12=="3")
CHB = which(data$V12=="4")
JPT = which(data$V12=="5")
YRI = which(data$V12=="6")

pdf(pdfname)
plot(0, 0, pch="", xlim=c(-0.2,0.2), ylim=c(-0.2,0.2),
     xlab="principal component 1", ylab="principal component 2")
points(data$V2[JPT], data$V3[JPT], pch=20, col="PURPLE")
points(data$V2[CHB], data$V3[CHB], pch=20, col="PURPLE")
points(data$V2[YRI], data$V3[YRI], pch=20, col="GREEN")
points(data$V2[CEU], data$V3[CEU], pch=20, col="RED")
par(cex=0.5)
points(data$V2[cont], data$V3[cont], pch="+", col="BLACK")
dev.off()
