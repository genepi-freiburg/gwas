# this is a template file that may be copied and adjusted to your needs

##### EXECUTABLES
ANNOVAR=/opt/annovar

##### DIRECTORIES

# Prefixes (only for this file)
DIR_PREFIX="/data/gwas/pediGFR_gwas"
DATA_DIR="${DIR_PREFIX}/dbGAP_CaseControl/Association/20130902-annotate/out"

# SNPtest output
SNPTEST_OUTPUT_DIR="${DIR_PREFIX}/dbGAP_CaseControl/Association/20130830/out"
SNPTEST_OUTPUT_FILE="${SNPTEST_OUTPUT_DIR}/%PHEN%/%ADJ%/%COHORT%.gwas"

##### PHENOTYPE

# Phenotype Variable Names
PHENOTYPE_NAMES="PHENO"

##### COHORTS

# Cohort Names
ALL_COHORTS="Data"

##### FILTERS
MINP=1E-6

