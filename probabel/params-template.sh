# this is a template file that may be copied and adjusted to your needs

##### EXECUTABLES
PROBABEL=/data/gwas/bin/probabel-0.4.3/bin/pacoxph

##### DIRECTORIES

# Prefixes (only for this file)
EXPERIMENT="PLEASE_GIVE_PATH"

# Data output directory
DATA_DIR="${EXPERIMENT}/out"

##### PHENOTYPE

# Phenotype table (must contain at least IID_COLUMN, SURV_TIME_COLUMN, EVENT_COLUMN and covariates)
PHENOTYPE_FILE="${EXPERIMENT}/phenotype.txt"

# Covariates file (fixed format, COHORT/COVARIATE, space-delimited)
# for cohort-dependent covariates

COVARIATE_FILE="${EXPERIMENT}/significant-pcs.txt"

# Fixed covariates (separate by comma)
FIXED_COVARIATES="SEX"

# Column names in phenotype file
IID_COLUMN="IID"
SURV_TIME_COLUMN="SURV_TIME"
EVENT_COLUMN="EVENT"

##### COHORTS

# Cohort Names
COHORTS="whites_4c whites_escape whites_ckid turks_4c turks_escape"

##### GENOTYPES

# Genotypes files (replace %COHORT% and %CHR% with cohort name and chromosome number)
MLDOSE_PATH="/data/gwas/pediGFR_gwas/TimeToEvent/01_Convert_Input/mldose/%COHORT%-chr%CHR%.mldose"
MLINFO_PATH="/data/gwas/pediGFR_gwas/TimeToEvent/01_Convert_Input/mlinfo/%COHORT%-chr%CHR%.mlinfo"
MAP_PATH="/data/gwas/pediGFR_gwas/TimeToEvent/01_Convert_Input/map/%COHORT%-chr%CHR%.map"
GEN_PATH="/data/gwas/pediGFR_gwas/Imputation/final/%COHORT%-chr%CHR%.gen"
SAMPLE_PATH="/data/gwas/pediGFR_gwas/Imputation/data/%COHORT%.sample"

### TECHNICAL

PROCESS_LIMIT="16"
