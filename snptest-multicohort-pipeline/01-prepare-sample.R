fam_path = Sys.getenv("FAM_PATH")
out_path = Sys.getenv("DATA_DIR")
phenos = Sys.getenv("PHENOTYPE_NAMES")
add_covars = Sys.getenv("ADDITIONAL_COVARIATE_NAMES")
add_covar_types = Sys.getenv("ADDITIONAL_COVARIATE_TYPES")
phen_name = Sys.getenv("PHENOTYPE_FILE")
cohorts = Sys.getenv("COHORTS")
pheno_types = Sys.getenv("PHENOTYPE_TYPES")
eigen_dim = Sys.getenv("PC_VECTOR_SIZE")
cov_name = Sys.getenv("COVARIATE_FILE")

if (is.na(add_covars)) {
  add_covars = ""
}

if (is.na(add_covar_types)) {
  add_covar_types = ""
}

if (length(unlist(strsplit(phenos," "))) != length(unlist(strsplit(pheno_types, " ")))) {
  print("phenotype_names and phenotype_types must be of same length!")
  quit(status=98)
}

acnl=length(strsplit(add_covars, " "))
actl=length(strsplit(add_covar_types, " "))
if (acnl == 1 & add_covars == "") { acnl = 0 }
if (actl == 1 & add_covar_types == "") { actl = 0 }
print(paste("acn '", add_covars, "', ", acnl, "; act '", add_covar_types, "', ", actl, sep=""))
if (acnl != actl) {
  print("add_covar_names and add_covar_types must be of same length!")
  quit(status=96)
}

if (nchar(add_covars > 0) | nchar(add_covar_types) > 0) {
  if (length(strsplit(add_covars, " ")) != length(strsplit(add_covar_types, " "))) {
    print("add_covar_types and add_covars must be of same length!")
    quit(status=99)
  }
}


# check COV file
print(paste("read covariate file '", cov_name, "'", sep=""))
cov_tab = data.frame(PHENO=0,FILE=0,COV=0)
cov_tab = cov_tab[-1,]
if (file.info(cov_name)$size > 0) {
  cov_tab = read.table(cov_name, sep=" ", h=F)
  if (ncol(cov_tab) != 3) {
	print("invalid covariate file (significant-pcs.txt)")
  	quit(status=89)
  }
  colnames(cov_tab) = c("PHENO", "FILE", "COV")
} else {
  print("empty COV table")
  colnames(cov_tab) = c("PHENO", "FILE", "COV")
}
summary(cov_tab)

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
  print(summary(fam))

  # merge without SEX to check for SEX mismatches
  samp <- merge(fam, data, all.x=T, by=c("IID", "FID")) # omit SEX

  if (("SEX.x" %in% colnames(samp)) & nrow(subset(samp, samp$SEX.x != samp$SEX.y)) > 0) {
	print("SEX mismatches! problems merging FAM file and phenotype data")
	print("Problematic rows:")
	print(subset(samp, samp$SEX.x != samp$SEX.y))
	quit(status=101)
  }

  # final merge (including SEX)
  print("merge FAM with phenotype data")
  samp <- merge(fam, data, all.x=T, by=c("IID", "FID", "SEX"))
  print(dim(samp))
  print(summary(samp))

  na_ages = subset(samp, is.na(samp$AGE))
  if (nrow(na_ages) > 0) {
  	print("NA ages:")
	print(subset(samp, is.na(samp$AGE)))
  } else {
	print("No NA ages - great!")
  }

  print("order sample in FAM order")
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

      # check
      if (covar %in% cov_tab$COV) {
	print(paste("ERROR: covar", covar, "in additional_covariables must not be in covariates file!"))
	quit(status=101)
      }
    }
  }
  print(paste("eigen_dim", eigen_dim))
  for (i in 1:eigen_dim) {
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
print(summary(data))

if (is.na(which(colnames(data) == "SEX"))) {
	print("ERROR: 'SEX' column (upper case) required in phenotype data. Must match FAM sex column!")
	quit(status=90)
}
if (is.na(which(colnames(data) == "AGE"))) {
	print("ERROR: 'AGE' column (upper case) required in phenotype data.")
	quit(status=91)
}

fns <- unlist(strsplit(cohorts, " "))
print(paste("fns", fns))

# check covars file
if (nrow(cov_tab)>0) {
for (i in 1:nrow(cov_tab)) {
	pheno = cov_tab[i, "PHENO"]
	fn = cov_tab[i, "FILE"]
	cov = cov_tab[i, "COV"]
        if (!(pheno %in% colnames(data))) {
                print(paste("phenotype name", pheno, "from covar file not found in data"))
		quit(status=92)
        }
	if (!(pheno %in% unlist(strsplit(phenos, " ")))) {
		print(paste("phenotype name", pheno, "from covar file not found in phenos parameter"))
		quit(status=95)
	}
	if (!(fn %in% fns)) {
		print(paste("group name", fn, "not found in 'cohorts'"))
		quit(status=93)
	}
	if (!(cov %in% colnames(data))) {
		print(paste("covariate name", cov, "not found in data"))
		quit(status=94)
	}
	print(paste("cov row correct; pheno", pheno, "group", fn, "cov", cov))
}
}

print ("INITIAL CHECKS SUCCEEDED - PREPARE DATA")

for (fn in unlist(fns)) {
	prepare_sample(fn)
}

print("finished SUCCESSFULLY")
