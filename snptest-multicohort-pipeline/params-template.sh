# this is a template file that may be copied and adjusted to your needs

##### EXECUTABLES
SNPTEST=/data/gwas/bin/snptest_v2.5-beta4_Linux_x86_64_static/snptest_v2.5-beta4

##### DIRECTORIES

# Prefixes (only for this file)
DIR_PREFIX="/data/gwas/pediGFR_gwas"
EXPERIMENT="${DIR_PREFIX}/Association/20130828"

# Data output directory
DATA_DIR="${EXPERIMENT}/out"

##### PHENOTYPE

# Phenotype Variable Names
PHENOTYPE_NAMES="LNEGFR_EXP_BASELINE LNEGFR_EXP_SLOPE LNEGFR_CYCR_BASELINE LNEGFR_CYCR_SLOPE PROTEINURIA GLOMERULAR"

# Phenotype Variable Types (C = continuous, D = discrete)
PHENOTYPE_TYPES="P P P P B B"

# Phenotype table (must contain FID, IID, AGE, E1..E10)
PHENOTYPE_FILE="${EXPERIMENT}/phenotype.txt"

# Covariates file (fixed format, COHORT/PHENOTYPE/COVARIATE)
COVARIATE_FILE="${EXPERIMENT}/significant-pcs.txt"

##### COHORTS

# Cohort Names
COHORTS="whites_4c whites_escape whites_ckid turks_4c turks_escape africans_ckid"

##### GENOTYPES

# Use one file per chromosome (1) or a single file for all chromosomes (0)
FILES_SEPARATE_BY_CHROMOSOME=1

# Genotypes GEN files (replace %COHORT% and %CHR% with cohort name and chromosome number)
GEN_PATH="${DIR_PREFIX}/Imputation/final/%COHORT%-chr%CHR%.gen"

# Genotypes FAM files
FAM_PATH="${DIR_PREFIX}/Imputation/input/%COHORT%.fam"



