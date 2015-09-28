#!/usr/bin/perl -w

use strict;
use List::Util qw(first); 
use Getopt::Std;

#########################
# read params and open files
#########################

my %opts;
getopt('mgcoh', \%opts);
my $genName = $opts{'g'};
my $mapName = $opts{'m'};
my $chrNumb = $opts{'c'};
my $outName = $opts{'o'};

if (exists $opts{'h'} || !$chrNumb || !$mapName || !$genName) {
	die "Usage: $0 -c <chromosome number> -g <input gen file> -m <map file> -o <output gen file>\n" .
		"Updates the GEN file using the chromosome number, allele codes and RS identifiers from the map.\n" .
		"Merges by position.";
}

if ($genName =~ /\.gz$/) {
  	open GEN, "gunzip -c $genName |" or die "Unable to open input GEN file: $!";
} else {
	open GEN, $genName or die "Unable to open input GEN file: $!";
}

open MAP, $mapName or die "Unable to open MAP file: $!";

if ($outName =~ /\.gz/) {
	open OUT, "| gzip > $outName" or die "Unable to create output GEN file: $!";
} else {
	open OUT, ">$outName" or die "Unable to create output GEN file: $!";
}

#########################
# read MAP
#########################

my %allAByPos, my %allBByPos, my %rsIdByPos;
my $counter = 0;
while (<MAP>) {
	my ($chr, $rsId, $genPos, $physPos, $allA, $allB) = split();
	die "Found invalid chromosome number $chr" if ($chr ne $chrNumb);
	warn "Duplicate position $physPos" if (exists $rsIdByPos{$physPos});
	$rsIdByPos{$physPos} = $rsId;
	$allAByPos{$physPos} = $allA;
	$allBByPos{$physPos} = $allB;
	$counter++;
}
close(MAP);

print STDOUT "Read " . $counter . " SNPs from MAP file.\n";


#########################
# convert GEN
#########################

$counter = 0;
while (<GEN>) {
	my @line = split(/ /);
	my $pos = $line[2];

	my $allA = $allAByPos{$pos};
	my $allB = $allBByPos{$pos};
	my $rsId = $rsIdByPos{$pos};
        if (!defined $allA || !defined $allB || !defined $rsId) {
                print STDERR "Position not found in MAP file: $pos\n";
		print OUT join(" ", @line);
                next;
        }

	$line[0] = $chrNumb;
	$line[1] = $rsId;
	$line[3] = $allA;
	$line[4] = $allB;

	$counter++;
	print OUT join(" ", @line);
}

print STDOUT "Wrote " . $counter . " SNPs to output GEN file.\n";

close(GEN);
close(OUT);
