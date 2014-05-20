#!/usr/bin/perl
# Script for creating GWAMA input file from GWAS association results file. 
# Use the script: "perl gwas2gwama.pl <GWAS output file> <output GWAMA file>"
$inputfile = $ARGV[0];
$outputfile = $ARGV[1];
$cMAF=$cMAC=$cN=$cPROPER=0;
for ($i=2; $i<scalar(@ARGV);$i++)
{
	@arg = split(/=/, $ARGV[$i]);
	if (uc($arg[0]) eq "N" && $arg[1]>0){print "N cut-off $arg[1]\n"; $cN=$arg[1];}
	if (uc($arg[0]) eq "MAC" && $arg[1]>0){print "MAC cut-off $arg[1]\n"; $cMAC=$arg[1];}
	if (uc($arg[0]) eq "MAF" && $arg[1]>0){print "MAF cut-off $arg[1]\n"; $cMAF=$arg[1];}
	if (uc($arg[0]) eq "PROPERINFO" && $arg[1]>0){print "PROPERINFO cut-off $arg[1]\n"; $cPROPER=$arg[1];}
}
if ($ARGV[0] eq "" || $ARGV[0] eq "-h" || $ARGV[0] eq "--help"){printhelp();exit;}
open F, "$inputfile" or die "Cannot file input file. This must be first command line argument!\n";
if ($outputfile eq ""){die "Please enter the outputfile name as second command line argument!\n";}
open O, ">$outputfile" or die "Cannot open $outputfile for writing. Please check folder's access rights and disk quota!\n";
print "Using BETA with SE output.\n";
print O "MARKER\tEA\tNEA\tBETA\tSE\tN\tEAF\tSTRAND\tIMPUTED\n";
$i=0;
LINE: while(<F>)
{
	chomp;
	next LINE if /^#/;
	@data = split(/\s/);
	if ($i==0)	#header line
	{
		#SNP     chr     position        coded_all       noncoded_all    strand_genome   beta    SE      pval    
		#AF_coded_all    HWE_pval        callrate        n_total imputed used_for_imp    oevar_imp
	}
	else		#snp line
	{
		$marker = $data[0];
		$ea = $data[3];
		$nea = $data[4];
		$beta = $data[6];
		$se = $data[7];
		$proper = $data[15];
		$n = $data[12];
		$eaf = $data[9];
		if ($eaf > 0.5) {
			$maf = 1-$eaf;
		}
		else {
			$maf=$eaf;
		}
		$strand = "+";
		$imp = $data[13];
	
		if ($cMAF > $maf || $cMAC>$maf*$n || $cN>$n || $cPROPER>$proper || $beta eq "NA" || $se eq "NA") {
		}
		else {
			print O "$marker\t$ea\t$nea\t$beta\t$se\t$n\t$eaf\t$strand\t$imp\n";
		}
	}
	$i++;
}
sub printhelp()
{
	print "Script for creating GWAMA input file from GWAS association results file.\n";
	print "Quantitative analysis:\n\tperl SNPTEST2_2_GWAMA.pl <GWAS output file> <output GWAMA file>\n";
	print "NB! Script expects that all markers are from positive strand. If not, Strand column must be modified with correct strand information.\n";
	print "Data can be filtered according to minimum number of samples (N), minor allele frequency (MAF), and minimum number of allele count (MAC = MAF*N)\n";
	print "All cut-offs must be entered after mandatory 2 command line options shown above.\n";
	print "Example: N=100 MAF=0.01 MAC=10 PROPER=0.4, will remove markers with less than 100 individuals, MAF<1% and MAC<10 and properinfo<0.4\n";
	print "Don't leave any spaces into the equations.\n";
	print "Example command line:\n\tperl gwas2gwama.pl <GWAS output file> <output GWAMA file> MAF=0.01 MAC=10\n";
}
