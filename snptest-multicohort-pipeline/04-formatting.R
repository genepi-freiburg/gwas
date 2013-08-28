# Formatting SNPTEST results

args <- commandArgs(TRUE)
fn = args[1]
print(paste("analyzing", fn))

formatting <- function(fn, adj) {
  result = data.frame()
  for (chromo in 1:22) {
    print(paste("reading",fn, adj, chromo))
    erg1 = read.table(paste(adj, "/", fn, "-chr", chromo, ".out", sep=""), header=T, as.is=T, sep=" ")

    Pcol = grep("_pvalue", names(erg1))
    erg1 = erg1[erg1[,Pcol] >= 0,]
 
    print(paste("formatting", fn, adj, chromo)) 
    table(erg1$id,useNA="always")
    out1=data.frame(
     SNP=erg1$rsid,
     chr=chromo,    #erg1$alternate_ids,
     position=erg1$position,
     coded_all=erg1$alleleB,
     noncoded_all=erg1$alleleA,
     strand_genome="+",  # DEPENDS ON YOUR DATA !!!! - Our data is on "+" strand
     beta=erg1[,grep("_beta_1",names(erg1))],
     SE=erg1[,grep("_se_1",names(erg1))],
     pval=erg1[,grep("_pvalue",names(erg1))[1]],
     AF_coded_all=(erg1$all_AB+2*erg1$all_BB)/(2*(erg1$all_AA+erg1$all_AB+erg1$all_BB)),
     HWE_pval=erg1$cohort_1_hwe,
     callrate = ifelse(erg1$alternate_ids=="---",1,round(1-(erg1$all_NULL/(erg1$all_AA+erg1$all_AB+erg1$all_BB+erg1$all_NULL)),4)),
     n_total=round(erg1$all_AA + erg1$all_AB + erg1$all_BB),
     imputed=ifelse(erg1$alternate_ids=="---",1,0),
     used_for_imp=ifelse(erg1$alternate_ids=="---",0,1),
     oevar_imp=erg1$info
    )
    dim(out1)
    summary(out1)
    result = rbind(result, out1)
  }

  print(paste("writing merged file", fn, adj))
  write.table(result, paste(adj, "/", fn, ".gwas", sep=""), sep="\t", na="NA", row.names=F, quote=F)
}

#fns <- c("whites_4c", "whites_escape", "turks_4c", "turks_escape", "whites_ckid", "africans_ckid")
#for (fn in fns) {
    formatting(fn, "adjusted")
    formatting(fn, "unadjusted")
#}

