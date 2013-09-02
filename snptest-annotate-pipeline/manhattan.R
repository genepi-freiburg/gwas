source("qqman.r")

plot_mh <- function(data, fn, pop, phen) {
  names(data)[names(data)=="SNPID"] <- "SNP"
  names(data)[names(data)=="chr"] <- "CHR"
  names(data)[names(data)=="position"] <- "BP"
  names(data)[names(data)=="pval"] <- "P"
  
  png(fn, width=1000, height=1000)
  main(paste(pop, phen))
  manhattan(data, annotate=snps_to_highlight)
  dev.off()
}

snps_to_highlight = c("rs2054576",
                      "rs13113918",
                      "rs3827143",
                      "rs2461700")
fns <- c("turks", "whites_4c", "whites_escape")
phen <- c("lnegfr", "uacid", "cystc")
for (fn in fns) {
for (ph in phen) {
  print(paste(fn, ph))
  data=read.table(paste("data/", fn, "-", ph, ".gwas", sep=""),h=T)
  fn2=paste("mh/", fn, "-", ph, ".png", sep="")
  plot_mh(data, fn2, fn, ph)
}
}
