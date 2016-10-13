#!/usr/bin/perl -w
use strict;
use Getopt::Std;

my %opts;
getopt('ioc', \%opts);
if (!exists $opts{'i'} or !exists $opts{'o'}) {
    print "Usage: $0 -i input_file -o output_file [-c chromosome_number]\nConverts EPACTS output file to a .gwas file.\n";
    exit;
}

if ($opts{'i'} !~ /\.epacts$/ && $opts{'i'} !~ /\.epacts\.gz$/) {
    die "Input file must end with .epacts or .epacts.gz!\n";
}

if ($opts{'o'} !~ /\.gwas$/) {
    die "Output file must end with .gwas!\n";
}

my $chr = "NA";
if (exists $opts{'c'}) {
    $chr = $opts{'c'};
} else {
    if ($opts{'i'} =~ /chr(\d+)/i) {
	$chr = $1;
	print "Auto-detected chromosome $chr.\n";
    }
}

if ($opts{'i'} =~ /\.gz$/) {
	print "Process gzipped input.\n";
	open(INPUT, "-|", "gunzip -c " . $opts{'i'}) or die "Input file not found!\n";
} else {
	open(INPUT, $opts{'i'}) or die "Input file not found!\n";
}
open(OUTPUT, ">" . $opts{'o'}) or die "Cannot open output file for writing!\n";

my $i = 0, my $pcol = -1, my $hwepcol = -1, my $casesHweCol = -1, my $controlsHweCol = -1, my $casesMafCol = -1, my $controlsMafCol = -1;
my @header;
my $skipped = 0, my $included = 0, my $errors = 0;

while (<INPUT>) {
    # read line
    my $line = $_;
    chomp($line);

    # print header
    $i++;
    if ($i == 1) {
	print OUTPUT "SNP\tchr\tposition\tcoded_all\tnoncoded_all\tstrand_genome\t";
	print OUTPUT "beta\tSE\tpval\tAF_coded_all\tHWE_pval\tcallrate\tn_total\t";
	print OUTPUT "imputed\tused_for_imp\toevar_imp\tcases_hwe\tcontrols_hwe\t";
	print OUTPUT "cases_maf\tcontrols_maf\n";
    }

# 0       1      2        3                       4      5       6               7        8      9        10      11         12  13        14          15
#CHROM  BEGIN   END     MARKER_ID                NS      AC      CALLRATE        MAF     PVALUE  BETA    SEBETA  CHISQ   NS.CASE NS.CTRL AF.CASE        AF.CTRL
#1       13380   13380   1:13380_C/G_1:13380     5034    0.025   1       2.4831e-06      NA      NA      NA      NA      1778    3256    1.1249e-06      3.2248e-06

    # skip comments / header in input
    if ($line =~ /^#/) {
	# skip header and comments
        next;
    }

    # split fields
    my @data = split(/\t/, $line);

    # marker name and alleles
    my $marker = $data[3];
    if ($marker !~ /^[^_]+\_(\w+)\/(\w+)\_[^\_]+$/) {
        print "ERROR: Marker name not parseable: $marker\n -> skip line\n";
        $errors++;
        next;
    }
    my $coded = $2, my $noncoded = $1;

    # chromosome number
    my $outchr;
    if ($chr ne "NA") {
	$outchr = $chr;
        if ($data[0] != $chr) {
            print "ERROR: Chromosome in line does not match passed chromosome and/or file name. Skip line.\n";
            $errors++;
            next;
        }
    } else {
	$outchr = $data[0];
    }

    # strand, beta/se/pval - TODO check numeric?
    my $beta = $data[9];
    my $se = $data[10];
    my $pval = $data[8];
    if ($beta eq "NA" || $se eq "NA" || $pval eq "NA") {
        $skipped++;
        next;
    }

    # START OUTPUT
    $included++;

    # marker, chromosome number and position
    print OUTPUT $marker . "\t";
    print OUTPUT $outchr . "\t"; # CHR
    print OUTPUT $data[1] . "\t"; # POS

    # alleles
    print OUTPUT $coded . "\t" . $noncoded . "\t"; # coded/non_coded

    # strand, beta/se/pval - TODO check numeric?
    print OUTPUT "+\t" . $beta . "\t" . $se . "\t" . $pval . "\t";

    # AF_coded_all
    print OUTPUT $data[7] . "\t"; # MAF

    # HWE
    print OUTPUT "NA\t";

    # callrate
    print OUTPUT $data[6] . "\t";

    # n_total
    print OUTPUT $data[4] . "\t";

    # imputation
    print OUTPUT "NA\tNA\tNA\t";

    # HWE cases/controls
    print OUTPUT "NA\tNA\t";

    # MAF cases/controls
    print OUTPUT $data[14] . "\t" . $data[15] . "\n";
}

close OUTPUT;
close INPUT;

print "Output file " . $opts{'o'} . " finished.\n";
print "Included $included SNPs, skipped $skipped SNPs, $errors errors, processed $i lines (with header).\n";

