#!/usr/bin/perl -w

use strict;
use List::Util qw(first); 
use Getopt::Std;

#########################
# read params and open files
#########################

my %opts;
getopts('m:g:o:hs', \%opts);
my $gwasName = $opts{'g'};
my $mapName = $opts{'m'};
my $outName = $opts{'o'};
my $simplifyRsId = $opts{'s'};

if (exists $opts{'h'} || !$gwasName || !$mapName || !$outName) {
	die "Usage: $0 -g <input gwas file> -m <RSID map file> -o <output gwas file> [-s]\n" .
		"Updates the GWAS file using the RS identifiers from the map.\n" .
		"Merges by first column of the map file (old RSID).\n" .
		"Adds a new column with the corresponding second column of the map.\n" .
		"The option '-s' simplifies RSIDs, i.e. strips pos/alleles.";
}

open GWAS, $gwasName or die "Unable to open input GWAS file: $!";
open MAP, $mapName or die "Unable to open MAP file: $!";
open OUT, ">$outName" or die "Unable to create output GWAS file: $!";

#########################
# read MAP
#########################

my %rsIdMap;
my $counter = 0;
while (<MAP>) {
	my ($rsId1, $rsId2) = split();
	warn "Duplicate RSID $rsId1 in mapping file" if (exists $rsIdMap{$rsId1});
	$rsIdMap{$rsId1} = $rsId2;
	$counter++;
}
close(MAP);

print STDOUT "Read " . $counter . " SNPs from MAP file.\n";


#########################
# convert GWAS
#########################

$counter = 0;
my $simplifiedCounter = 0, my $mappedCounter = 0;

while (<GWAS>) {
	my @line = split(/\s/);
	if ($counter == 0) {
		# header line
		push(@line, "ORIG_RSID");
		print OUT join("\t", @line) . "\n";
		$counter++;
		next;
	}

	my $rsId1 = $line[0];

	my $rsId2 = $rsIdMap{$rsId1};

        if (!defined $rsId2) {
		# this is ok for non-kgp SNPs
		if ($rsId1 =~ /^kgp/) {
                	print STDERR "RSID not found in MAP file: $rsId1\n";
		}
        } else {
		# successfully mapped	
		$line[0] = $rsId2;
		$mappedCounter++;
	}

	chomp($line[$#line]);
	$line[$#line+1] = $rsId1 . "\n";

	if (defined $simplifyRsId && !defined $rsId2) {
		# not mapped; try normalization
		if ($rsId1 =~ /(rs[0-9]+):/) {
			#print STDERR "normalized $rsId1 to: $1\n";
			$line[0] = $1;
			$simplifiedCounter++;
		}
	}

	$counter++;
	print OUT join("\t", @line);
}

print STDOUT "Wrote " . ($counter-1) . " SNPs to output file.\n";
print STDOUT "Simplified " . ($simplifiedCounter) . " RS identifiers.\n";
print STDOUT "Successfully mapped " . ($mappedCounter) . " RS identifiers.\n";

close(GWAS);
close(OUT);
