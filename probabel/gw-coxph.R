#### ARGUMENTS

args = commandArgs(trailingOnly=T)
in_dose = args[1]
in_pheno = args[2]
in_maf_file = args[3] #"whites_ckid-chr22.snp-freqs.txt"
out_ass = args[4]

#### GENOTYPES

print(paste("reading genotypes from", in_dose))
geno = read.table(in_dose)
print("finished reading genotypes")

nind = ncol(geno)-5
nsnp = nrow(geno)

map = geno[,1:5]
colnames(map) = c("SNPID", "RSID", "POS", "ALL1", "ALL2")

geno = geno[,6:(nind+5)]
geno = as.matrix(geno)

#### PHENOTYPES

print(paste("reading phenotypes from", in_pheno))
pheno = read.table(in_pheno, h=T)
stopifnot(ncol(geno) == nrow(pheno))

rownames(geno) = map$RSID
colnames(geno) = pheno$IID

#### SURVIVAL TIME AND NULL MODEL

library("methods") # for "is"
library("survival")
kidney_surv = with(pheno, Surv(SURV_TIME, EVENT))

print("construct zero model")
model_zero = coxph(kidney_surv ~ pheno$SEX + pheno$AGE_BASELINE + pheno$EGFR_EXP_BASELINE)
loglik_zero = model_zero$loglik[2]
print(model_zero)

#### SNP LOOP

result = data.frame(snp=map$RSID, beta=NA, se=NA, chisq_lrt=NA, pval_lrt=NA, chisq_wald=NA, chisq_lrt=NA, info=NA)

options(warn=-1)
for (i in 1:nsnp) {
  if ((i %% 1000) == 0) { print(paste("processing SNP", i)) }
  snp = geno[i,]
  if (any(is.na(snp))) {
    print(paste("WARNING: Genotype data contains NA values; LRT chisq inaccurate for SNP", map[i, "RSID"]))
  }

  make_model = function() { coxph(kidney_surv ~ snp + pheno$SEX + pheno$AGE_BASELINE + pheno$EGFR_EXP_BASELINE) }
  model = tryCatch(make_model(), warning=function(w){w}, error=function(e){e})
  if (is(model, "warning")) { 
    status = paste("WARNING:", model)
    model = NULL
  } else if (is(model, "error")) {
    status = paste("ERROR:", model)
    model = NULL
  } else {
    status = "OK"
  }
  
  if (!is.null(model)) {
    beta = model$coefficients[1]
    se = sqrt(diag(model$var))[1]
    
    chisq_wald = (beta / se) ^ 2
    pval_wald = pchisq(chisq_wald, df=1, lower.tail=F)
    
    loglik = model$loglik[2]
    chisq_lrt = 2 * (loglik - loglik_zero)
    pval_lrt = pchisq(chisq_lrt, df=1, lower.tail=F)
    
    result[i, "beta"] = beta
    result[i, "se"] = se
    result[i, "chisq_lrt"] = chisq_lrt
    result[i, "pval_lrt"] = pval_lrt
    result[i, "chisq_wald"] = chisq_wald
    result[i, "pval_wald"] = pval_wald
  } 

  result[i, "info"] = status
}
options(warn=0)

#### FREQUENCIES

print(paste("reading frequencies from", in_maf_file))
maf = read.table(in_maf_file, h=T)
print("frequencies read")

maf = data.frame(RSID=maf$RSID,MAF=maf$MAF)
stopifnot(nrow(maf) == nrow(result))

map = cbind(map, maf$MAF)
colnames(map)[6] = "MAF"

#### CHECK AND MERGE RESULT
result = cbind(map, result)
errors = which(result$snp != result$RSID)
stopifnot(length(errors) == 0) # check SNP order 
result$snp = NULL

print(paste("writing result to", out_ass))
write.table(result, out_ass, row.names=F, col.names=T, quote=F, sep="\t")
print("finished")
