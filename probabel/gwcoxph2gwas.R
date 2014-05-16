args <- commandArgs(trailingOnly = TRUE)
infn = args[1]
outfn = args[2]
freqfn = args[3]
chrnum = args[4]

print("read gw-coxph result")
indat = read.table(infn, h=T)
summary(probable)

#name A1 A2 Freq1 MAF Quality Rsq n Mean_predictor_allele chrom position beta_SNP_add sebeta_SNP_add chi2_SNP
#"SNPID", "RSID", "POS", "ALL1", "ALL2"   MAF beta se chisq_lrt pval_lrt chisq_wald pval_wald
#SNP     chr     position        coded_all       noncoded_all    strand_genome   beta    SE      pval    AF_coded_all    HWE_pval        callrate        n_total imputed used_for_imp    oevar_imp
out = data.frame(
	SNP=indat$RSID,
	chr=chrnum,
	position=indat$POS,
	coded_all=indat$ALL1,
	noncoded_all=indat$ALL2,
	strand_genome="+",
	beta=indat$beta,
	SE=indat$se,
	pval=indat$pval_wald,
	AF_coded_all=-1,            		# -1, wird ersetzt
	HWE_pval=1,
	callrate=-1,		              	# -1, wird ersetzt
	n_total=-1,				# wird ersetzt
	imputed=0, 				# wird ersetzt
	used_for_imp=1, 			# wird ersetzt
	oevar_imp=1 				# haben wir derzeit nicht, aber "information" measure
	)
summary(out)

rm(indat)

print("read SNP freqs")
freqs = read.table(freqfn, h=T)
summary(freqs)

# SNPID RSID chromosome position A_allele B_allele minor_allele major_allele AA AB BB       AA_calls AB_calls BB_calls MAF HWE missing missing_calls information
# --- rs190080431 NA 16462950    G T T G                                     268.96 1.043 0 269 1 0                    0.0019315 -0 0 0 0.9012
# rs35416799 rs35416799 NA 16869887 G A A G                                  240 30 0       240 30 0                   0.055556 -0 0 0 1

freq_short = data.frame(
        SNP=freqs$RSID,
	A1FREQ=(2 * freqs$AA + freqs$AB)/(2*(freqs$AA+freqs$AB+freqs$BB)),
	CALLRA=1-freqs$missing,
	IMPUTD=(freqs$SNPID == "---"),
	NTOT=freqs$AA+freqs$AB+freqs$BB,
	INFORM=freqs$information)
rm(freqs)

final = merge(out, freq_short, all.x=T, by="SNP")

final$AF_coded_all = final$A1FREQ
final$callrate = final$CALLRA
final$imputed = ifelse(final$IMPUTD, 1, 0)
final$used_for_imp = ifelse(final$IMPUTD, 0, 1)
final$oevar_imp = final$INFORM
final$n_total = final$NTOT

final$A1FREQ = NULL
final$CALLRA = NULL
final$IMPUTD = NULL
final$INFORM = NULL
final$NTOT   = NULL

write.table(final, outfn, row.names=F, col.names=T, quote=F, sep="\t")
