args <- commandArgs(trailingOnly = TRUE)
inputpathname = args[1]
outputpathname = args[2]

het = read.table(paste(inputpathname, ".het", sep=""), h=T)
het$meanHet = (het$N.NM. - het$O.HOM.) / het$N.NM.

summstr = paste(summary(het$meanHet), collapse=", ")
cat(paste("Min, 25%, 50%, Mean, 75%, Max = ", summstr, "\n", sep=""), file=outputpathname)
cat(paste("SD = ", sd(het$meanHet), "\n", sep=""), file=outputpathname, append=T)

sdMeanHet = sd(het$meanHet)
meanMeanHet = mean(het$meanHet)
for (i in 2:6) {
  b1 = meanMeanHet+i*sdMeanHet
  b2 = meanMeanHet-i*sdMeanHet
  outliers = length(which(het$meanHet > b1 | het$meanHet < b2))
  cat(paste("heterozygosity outliers for ", i, " SD: ", outliers, "\n", sep=""), file=outputpathname, append=T)
}
