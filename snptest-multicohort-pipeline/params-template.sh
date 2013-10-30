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

# Phenotype Variable Types (P = continuous, B = binary)
PHENOTYPE_TYPES="P P P P B B"

# Phenotype table (must contain FID, IID, AGE, E1..E10)
PHENOTYPE_FILE="${EXPERIMENT}/phenotype.txt"

# Covariates file (fixed format, COHORT/PHENOTYPE/COVARIATE)
COVARIATE_FILE="${EXPERIMENT}/significant-pcs.txt"

# PC vector dimension
PC_VECTOR_SIZE="10"

# additional covariates (besides AGE, SEX, E1..10; must also be contained in covariate file)
ADDITIONAL_COVARIATE_NAMES=""

# covariate types (C = continuous, D = binary)
ADDITIONAL_COVARIATE_TYPES=""

# skip unadjusted analysis (0/1)
SKIP_UNADJUSTED_ANALYSIS="0"

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

### TECHNICAL
PROCESS_LIMIT="16"
