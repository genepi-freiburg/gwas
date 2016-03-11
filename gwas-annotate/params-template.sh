# this is a template file that may be copied and adjusted to your needs

##### EXECUTABLES
ANNOVAR=/opt/annovar

##### DIRECTORIES

# Prefixes (only for this file)
DIR_PREFIX="/data/gwas/XXXXX"
DATA_DIR="${DIR_PREFIX}/annotate"

# SNPtest output
SNPTEST_OUTPUT_DIR="${DIR_PREFIX}/out"
SNPTEST_OUTPUT_FILE="${SNPTEST_OUTPUT_DIR}/%PHEN%/%ADJ%/%COHORT%.gwas"

##### PHENOTYPE

# Phenotype Variable Names
PHENOTYPE_NAMES="PHENO"

##### COHORTS

# Cohort Names
ALL_COHORTS="Data"

##### FILTERS
# p-value filter border (only keep p values less than the border)
P_BORDER=1E-4

# HWE p-value filter border (only keep HWE p values bigger than the border)
HWE_BORDER=1E-5

# MAF (minor allele frequency) border (only keep MAFs above the border)
MAF_BORDER=0.01

##### PARAMETERS

# make a Manhattan plot (this takes some time)
DO_PLOT=1

# use 5% MAF filter for Manhatten plot
MANHATTAN_MAF_FILTER=0.05

# skip unadjusted analyses
SKIP_UNADJUSTED=0

# make LocusZoom plots
DO_LZ=1

# Locus Zoom LD Source ("1000G_March2012" or "1000G_Nov2014")
LZ_SOURCE="1000G_March2012"

# MAF filter before running LocusZoom
LZ_MAF_FILTER=0.05
