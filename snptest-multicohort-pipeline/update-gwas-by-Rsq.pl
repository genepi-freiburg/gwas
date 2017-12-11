#!/usr/bin/perl -w

use strict;
use List::Util qw(first);
use Getopt::Std;

#########################
# read params and open files
#########################

my %opts;
getopts('m:g:o:h', \%opts);
my $gwasName = $opts{'g'};
my $mapName = $opts{'m'};
my $outName = $opts{'o'};

if (exists $opts{'h'} || !$gwasName || !$mapName || !$outName) {
	die "Usage: $0 -g <input gwas file> -m <Rsq map file> -o <output gwas file>\n" .
		"Updates the GWAS file using the Rsq from the info files.\n" .
		"Merges by chr, position and alleles columns in GWAS file.\n" .
		"Adds a new column with the corresponding Rsq in the map.\n";
}

open GWAS, $gwasName or die "Unable to open input GWAS file: $!";
open MAP, $mapName or die "Unable to open MAP file: $!";
open OUT, ">$outName" or die "Unable to create output GWAS file: $!";

#########################
# read MAP
#########################

my %RsqMap;
my $counter = 0;
while (<MAP>) {
	my @mline = split(/\t/);
	$RsqMap{$mline[0] . ":". $mline[6]. ":" . $mline[5]} = $mline[9];
	$counter++;
}
close(MAP);

print STDOUT "Read " . $counter . " SNPs from MAP file.\n";

#########################
# convert GWAS
#########################

$counter = 0;
my $mappedCounter = 0;

while (<GWAS>) {
	chomp();
	my @line = split(/\t/);
	if ($counter == 0) {
		# header line
		push(@line, "ORIG_oevar_imp");
		print OUT join("\t", @line) . "\n";
		$counter++;
		next;
	}

	my $Id = join(":", $line[1], $line[2], $line[3], $line[4]);
	my $rsq = $RsqMap{$Id};
	my $rsq_orig = $line[15];

        if (!defined $rsq) {
		# this should not happen
		die "Unable to find Rsq for $Id.\n";
        } else {
		# successfully mapped	
		$line[15] = $rsq;
		$mappedCounter++;
	}

	chomp($line[$#line]);
	$line[$#line+1] = $rsq_orig . "\n";

	$counter++;
	print OUT join("\t", @line);
}

print STDOUT "Wrote " . ($counter-1) . " SNPs to output file.\n";
print STDOUT "Successfully converted " . ($mappedCounter) . " SNPs.\n";

close(GWAS);
close(OUT);
