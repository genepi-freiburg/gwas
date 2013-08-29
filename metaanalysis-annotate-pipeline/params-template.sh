# this is a template file that may be copied and adjusted to your needs

##### EXECUTABLES
ANNOVAR=
GWAMA=
GWAMA_CONVERT=~/bin/gwama/SNPTEST2.5_2_GWAMA.pl

##### DIRECTORIES

# Prefixes (only for this file)
DIR_PREFIX="/data/gwas/pediGFR_gwas"
DATA_DIR="${DIR_PREFIX}/Metaanalysis/20130829/out"

# SNPtest output
SNPTEST_OUTPUT_DIR="${DIR_PREFIX}/Association/20130828/out"
SNPTEST_OUTPUT_FILE="${SNPTEST_OUTPUT_DIR/%PHEN%/%ADJ%/%COHORT%-chr%CHR%.out

##### PHENOTYPE

# Phenotype Variable Names
PHENOTYPE_NAMES="LNEGFR_EXP_BASELINE LNEGFR_EXP_SLOPE LNEGFR_CYCR_BASELINE LNEGFR_CYCR_SLOPE PROTEINURIA GLOMERULAR"

# Phenotype Variable Types (P = continuous, B = binary)
PHENOTYPE_TYPES="P P P P B B"

##### COHORTS

# Cohort Names
ALL_COHORTS="whites_4c whites_escape whites_ckid turks_4c turks_escape africans_ckid"

# Metaanalysis Groups
GROUPS="ALL WHITES TURKS"
GROUPS_ALL="${ALL_COHORTS}"
GROUPS_WHITES="whites_4c whites_escape whites_ckid"
GROUPS_TURKS="turks_4c turks_escape"

##### FILTERS
MAF=0.01
MINN=50

