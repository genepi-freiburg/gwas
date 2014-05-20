# this is a template file that may be copied and adjusted to your needs

##### EXECUTABLES
GWAMA=/data/gwas/bin/gwama/GWAMA
ANNOVAR=/opt/annovar

##### DIRECTORIES

# Prefixes (only for this file)
DATA_DIR="/data/gwas/pediGFR_gwas/TimeToEvent/03-Metaanalysis/xxx/out"

# GWAS output
GWAS_OUTPUT="${DIR_PREFIX}/Association/20130828/out/%COHORT%.gwas"

##### COHORTS

# Cohort Names
ALL_COHORTS="whites_4c whites_escape whites_ckid turks_4c turks_escape"

# Metaanalysis Groups
METAANALYSIS_GROUPS="ALL WHITES TURKS"
GROUPS_ALL="${ALL_COHORTS}"
GROUPS_WHITES="whites_4c whites_escape whites_ckid"
GROUPS_TURKS="turks_4c turks_escape"

##### FILTERS
MAF=0.01
MINN=50

# options for genomic correction
# specify "-gc" to employ GC for input
# specify "-gco" to employ GC for output
# specify "-gc -gco" for double GC
GC_OPTS="-gc -gco"

