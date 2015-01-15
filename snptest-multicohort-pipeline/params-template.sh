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

# Phenotype Variable Names, space delimited
PHENOTYPE_NAMES="LNEGFR_EXP_BASELINE LNEGFR_EXP_SLOPE LNEGFR_CYCR_BASELINE LNEGFR_CYCR_SLOPE PROTEINURIA GLOMERULAR"

# Phenotype Variable Types (P = continuous, B = binary), space delimited
PHENOTYPE_TYPES="P P P P B B"

# Phenotype table (must contain FID, IID, AGE, E1..E10), readable by R (e.g., tab/space delimited, may have quotes)
PHENOTYPE_FILE="${EXPERIMENT}/phenotype.txt"

# Covariates file (fixed format, COHORT/PHENOTYPE/COVARIATE, space delimited)
COVARIATE_FILE="${EXPERIMENT}/significant-pcs.txt"

# PC vector dimension
PC_VECTOR_SIZE="10"

# additional covariates (besides AGE, SEX, E1..10; must not be contained in covariate file), space delimited
ADDITIONAL_COVARIATE_NAMES=""

# covariate types (C = continuous, D = binary), space delimited
ADDITIONAL_COVARIATE_TYPES=""

# skip unadjusted analysis (0/1)
SKIP_UNADJUSTED_ANALYSIS="1"

# skip X chromosome (SNPtest crashes at the moment)
SKIP_CHR_X="1"

# use phenotype normalization (0) or turn it off (1)
RAW_PHENOTYPES="1"

# calculate only certain chromosomes (space delimited)
# empty/not set = calculate all 22 chromosomes (and X, if not SKIP_CHR_X)
#ONLY_CHRS="4"

##### COHORTS/GROUPS

# Cohort Names
COHORTS="whites_4c whites_escape whites_ckid turks_4c turks_escape africans_ckid"

##### GENOTYPES

# Use one file per chromosome (1) or a single file for all chromosomes (0)
FILES_SEPARATE_BY_CHROMOSOME=1

# Genotypes GEN files (replace %COHORT% and %CHR% with cohort name and chromosome number)
# may also use .gz suffix
GEN_PATH="${DIR_PREFIX}/Imputation/final/%COHORT%-chr%CHR%.gen"

# Genotypes FAM files
FAM_PATH="${DIR_PREFIX}/Imputation/input/%COHORT%.fam"

### TECHNICAL
# Number of processors to use in parallel
PROCESS_LIMIT="16"

# Dimensions of PC vector (10)
PC_VECTOR_SIZE="10"

# Model to calculate (SNPtest frequentist parameter)
# 1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote
FREQUENTIST_MODEL="1"
