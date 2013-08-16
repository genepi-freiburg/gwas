args <- commandArgs(trailingOnly = TRUE)
inputpathname = args[1]
outputpathname = args[2]
hetlinesd = as.numeric(args[3])
missingnessline = as.numeric(args[4])
print(paste("plotting with sd =", hetlinesd, "and miss =s", missingnessline))

imiss = read.table(paste(inputpathname, ".imiss", sep=""), h=T)
imiss$logF_MISS = log10(imiss[,6])

het = read.table(paste(inputpathname, ".het", sep=""), h=T)
het$meanHet = (het$N.NM. - het$O.HOM.) / het$N.NM.

library("geneplotter")
colors  <- densCols(imiss$logF_MISS, het$meanHet)

pdf(outputpathname)
plot(imiss$logF_MISS, het$meanHet, col=colors, xlim=c(-3,0),
     ylim=c(0,0.5), pch=20, xlab="Proportion of missing genotypes", 
     ylab="Heterozygosity rate", axes=F)
axis(2, at=c(0,0.05,0.10,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5), tick=T)
axis(1, at=c(-3,-2,-1,0), labels=c(0.001,0.01,0.1,1))
abline(h=mean(het$meanHet) - (hetlinesd*sd(het$meanHet)), col="RED", lty=2)
abline(h=mean(het$meanHet) + (hetlinesd*sd(het$meanHet)), col="RED", lty=2)
abline(v=log10(missingnessline), col="RED", lty=2)
