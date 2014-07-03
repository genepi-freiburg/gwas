fam_path = Sys.getenv("FAM_PATH")
out_path = Sys.getenv("DATA_DIR")
phenos = Sys.getenv("PHENOTYPE_NAMES")
add_covars = Sys.getenv("ADDITIONAL_COVARIATE_NAMES")
add_covar_types = Sys.getenv("ADDITIONAL_COVARIATE_TYPES")
phen_name = Sys.getenv("PHENOTYPE_FILE")
cohorts = Sys.getenv("COHORTS")
pheno_types = Sys.getenv("PHENOTYPE_TYPES")
eigen_dim = Sys.getenv("PC_VECTOR_SIZE")

if (is.na(add_covars)) {
  add_covars = ""
}

if (is.na(add_covar_types)) {
  add_covar_types = ""
}

if (length(strsplit(phenos," ")) != length(strsplit(pheno_types," "))) {
  print("phenotype_names and phenotype_types must be of same length!")
  quit(status=98)
}

if (nchar(add_covars > 0) | nchar(add_covar_types) > 0) {
  if (length(strsplit(add_covars, " ")) != length(strsplit(add_covar_types, " "))) {
    print("add_covar_types and add_covars must be of same length!")
    quit(status=99)
  }
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
  fam$IDX = 1:nrow(fam)
  print(dim(fam))
  print(head(fam))
  
  samp <- merge(fam, data, all.x=T, by=c("IID", "FID", "SEX"))
  print(dim(samp))
  print(head(samp))
  samp=samp[order(samp$IDX),]
  samp$IDX = NULL
  
  if(nrow(samp)!=nrow(fam)) {
    print("sample and fam file must have same length - invalid phenotype file")
    quit(status=99)
  }

  result = data.frame(FID=samp$FID, IID=samp$IID,
        MISSING=0, SEX=samp$SEX, AGE=samp$AGE)

  print(paste("phenos =", phenos))
  for (pheno in unlist(strsplit(phenos, " "))) {
    print(paste("add pheno =", pheno))
    result[,pheno] = samp[,pheno]
    print("summary of this pheno")
    print(summary(result[,pheno]))
  }
  if (nchar(add_covars) > 0) {
    print(paste("add_covars =", add_covars))
    for (covar in unlist(strsplit(add_covars, " "))) {
      result[,covar] = samp[,covar]
    }
  }
  for (i in seq(1,eigen_dim)) {
    pc = paste("E",i,sep="")
    result[,pc]=samp[,pc]
  }
  head(result)

  # TODO check phenotype (B = 0/1 only)

  print(paste("eigen-dim", eigen_dim))

  outfn = paste(out_path, "/sample/", fn, ".sample", sep="")

  es = ""
  cs = ""
  for (i in 1:eigen_dim) {
    if (nchar(es) == 0) {
      es = paste("E", i, sep="")
      cs = "C"
    } else {
      es = paste(es, " E", i, sep="")
      cs = paste(cs, "C")
    }
  }

  print(paste("phenos", phenos, "add covars", add_covars, "es", es, 
              "pheno_types", pheno_types, "covar_types", add_covar_types, "cs", cs))
 
  if (nchar(add_covars) > 0) { 
    cat(paste("ID_1 ID_2 MISSING SEX AGE", phenos, add_covars, es,
              "\n0 0 0 D C",
              pheno_types, add_covar_types, cs, "\n"), file=outfn)
  } else {
    cat(paste("ID_1 ID_2 MISSING SEX AGE", phenos, es,
              "\n0 0 0 D C",
              pheno_types, cs, "\n"), file=outfn)
  }
  write.table(result, outfn, append=T, row.names=F, col.names=F, quote=F)
}

print(paste("read phenotypes", phen_name))
data <- read.table(phen_name, h=T)
dim(data)
print(head(data))

fns <- strsplit(cohorts, " ")
for (fn in unlist(fns)) {
  print(paste("prepare", fn))
  prepare_sample(fn)
}
print("finished")
