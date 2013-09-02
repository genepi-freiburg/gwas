fam_path = Sys.getenv("FAM_PATH")
out_path = Sys.getenv("DATA_DIR")
phenos = Sys.getenv("PHENOTYPE_NAMES")
phen_name = Sys.getenv("PHENOTYPE_FILE")
cohorts = Sys.getenv("COHORTS")
pheno_types = Sys.getenv("PHENOTYPE_TYPES")

if (length(strsplit(phenos," ")) != length(strsplit(pheno_types," "))) {
  print("phenotype_names and phenotype_types must be of same length!")
  quit(status=98)
}

prepare_sample <- function(fn) 
{
  print(paste("prepare", fn))
  my_fam = gsub("%COHORT%", fn, fam_path)

  print(paste("use fam", my_fam))

  fam <- read.table(my_fam, h=F)
  colnames(fam) <- c("FID", "IID", "MISSING", "B", "SEX", "PHENO")
  fam$PHENO <- NULL
  fam$B <- NULL
  fam$MISSING = 0
  print(dim(fam))
  print(head(fam))
  
  samp <- merge(fam, data, all.x=T)
  print(dim(samp))
  print(head(samp))

  if(nrow(samp)!=nrow(fam)) {
    print("sample and fam file must have same length - invalid phenotype file")
    quit(status=99)
  }

  result = data.frame(FID=samp$FID, IID=samp$IID,
        MISSING=0, SEX=samp$SEX, AGE=samp$AGE)

  for (pheno in unlist(strsplit(phenos, " "))) {
    result[,pheno] = samp[,pheno]
  }
  for (i in seq(1,10)) {
    pc = paste("E",i,sep="")
    result[,pc]=samp[,pc]
  }
  head(result)

  # TODO check phenotype (B = 0/1 only)

  outfn = paste(out_path, "/sample/", fn, ".sample", sep="")
  
  cat(paste("ID_1 ID_2 MISSING SEX AGE", phenos, 
            "E1 E2 E3 E4 E5 E6 E7 E8 E9 E10\n0 0 0 D C",
            pheno_types, "C C C C C C C C C C\n"), file=outfn)
  write.table(result, outfn, append=T, row.names=F, col.names=F, quote=F)
}

print(paste("read phenotypes", phen_name))
data <- read.table(phen_name, h=T)
dim(data)
print(head(data))

fns <- strsplit(cohorts, " ")
for (fn in unlist(fns)) {
  prepare_sample(fn)
}
