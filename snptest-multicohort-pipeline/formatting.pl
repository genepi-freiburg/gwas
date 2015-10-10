#!/usr/bin/perl -w

use Getopt::Std;
use strict;

sub round {
  my $float = $_[0];
  return int($float + $float/abs($float*2));
}

my %opts;
getopt('ioc', \%opts);
if (!exists $opts{'i'} or !exists $opts{'o'}) {
    print "Usage: $0 -i input_file -o output_file [-c chromosome_number]\nConverts SNPtest 2.5 .out file to a .gwas file.\n";
    exit;
}

if ($opts{'i'} !~ /\.out$/i) {
    die "Input file must end with .out!\n";
}

if ($opts{'o'} !~ /\.gwas$/i) {
    die "Output file must end with .gwas!\n";
}

my $chr = "NA";
if (exists $opts{'c'}) {
    $chr = $opts{'c'};
}

open(INPUT, $opts{'i'}) or die "Input file not found!\n";
open(OUTPUT, ">" . $opts{'o'}) or die "Cannot open output file for writing!\n";

my $i = 0, my $pcol = -1, my $hwepcol = -1, my $casesHweCol = -1, my $controlsHweCol = -1, my $casesMafCol = -1, my $controlsMafCol = -1;
my @header;
my $skipped = 0, my $included = 0;

while (<INPUT>) {
    my $line = $_;
    chomp($line);
    if ($line =~ /^#/) {
        next;
    }
	
    my @data = split(/ /, $line);
	
	if ($i == 0) {
	  @header = @data;
	  my ( $Pcol ) = grep { $header[$_] =~ /_pvalue/ } 0..$#header;
	  my ( $Hwepcol ) = grep { $header[$_] =~ /_hwe/ } 0..$#header;
	  $pcol = $Pcol;
	  die "No P value found in header!\n" if $pcol < 1;
	  $hwepcol = $Hwepcol;
	  die "No HWE P value found in header!\n" if $hwepcol < 1;
	  my ( $casesHweColX ) = grep { $header[$_] =~ /cases_hwe/ } 0..$#header;
	  if ($casesHweColX) { $casesHweCol = $casesHweColX; }
	  my ( $controlsHweColX ) = grep { $header[$_] =~ /controls_hwe/ } 0..$#header;
	  if ($controlsHweColX) { $controlsHweCol = $controlsHweColX; }
	  my ( $casesMafColX ) = grep { $header[$_] =~ /cases_maf/ } 0..$#header;
          if ($casesMafColX) { $casesMafCol = $casesMafColX; }
	  my ( $controlsMafColX ) = grep { $header[$_] =~ /controls_maf/ } 0..$#header;
          if ($controlsMafColX) { $controlsMafCol = $controlsMafColX; }

	  if ($casesHweCol > -1 && $controlsHweCol > -1) {
	    print "Output HWE p-value and MAF separately for cases/controls as well.\n";
	    print OUTPUT "SNP\tchr\tposition\tcoded_all\tnoncoded_all\tstrand_genome\tbeta\tSE\tpval\tAF_coded_all\tHWE_pval\tcallrate\tn_total\timputed\tused_for_imp\toevar_imp\tcases_hwe\tcontrols_hwe\tcases_maf\tcontrols_maf\n";
	  } else {
	    print "Only overall HWE p-value and MAF output.\n";
	    print OUTPUT "SNP\tchr\tposition\tcoded_all\tnoncoded_all\tstrand_genome\tbeta\tSE\tpval\tAF_coded_all\tHWE_pval\tcallrate\tn_total\timputed\tused_for_imp\toevar_imp\n";
	  }
	} else {
	  my $pval = $data[$pcol];
	  if ($pval ne "NA" && $pval >= 0) {
	    my $all_AA = $data[13];
	    my $all_AB = $data[14];
	    my $all_BB = $data[15];
	    my $all_NULL = $data[16];

	    my $SNP = $data[1]; #rsid
	    $chr = $data[0] if $chr eq "NA"; # use alt ID as chrom if not specified on cmd line
	    my $position = $data[3];
            my $coded_all = $data[5];
  	    my $noncoded_all = $data[4];
            my $strand_genome = "+";
            my $beta = $data[$pcol+2];
	    my $SE = $data[$pcol+3];
	    my $n_total = round($all_AA + $all_AB + $all_BB);
	    my $AF_coded_all = ($all_AB+2*$all_BB)/(2*($all_AA+$all_AB+$all_BB));
	    my $HWE_pval = $data[$hwepcol];
	    
	    my $callrate;
	    if($data[0] eq "---") {
	      $callrate = 1;
            } else {
              $callrate = round((1-($all_NULL/($all_AA+$all_AB+$all_BB+$all_NULL)))*10000)/10000;
	    }

	    my $imputed = 0;
	    if ($data[0] eq "---") {
		$imputed = 1;
	    }

	    my $used_for_imp = 1 - $imputed;
	    my $oevar_imp = $data[8];

	    print OUTPUT "$SNP\t$chr\t$position\t$coded_all\t$noncoded_all\t$strand_genome\t$beta\t$SE\t$pval\t$AF_coded_all\t$HWE_pval\t$callrate\t$n_total\t$imputed\t$used_for_imp\t$oevar_imp\t";
	    if ($casesHweCol > -1 && $controlsHweCol > -1) {
	      print OUTPUT $data[$casesHweCol]. "\t" . $data[$controlsHweCol] . "\t" . $data[$casesMafCol] . "\t" . $data[$controlsMafCol] . "\n";
	    } else {
	      print OUTPUT "\n";
	    }
	    $included++;
	  } else {
	    $skipped++;
	  }
	}

	$i++;
}

close OUTPUT;
close INPUT;

print "Output file " . $opts{'o'} . " finished; included $included SNPs, skipped $skipped SNPs.\n";


