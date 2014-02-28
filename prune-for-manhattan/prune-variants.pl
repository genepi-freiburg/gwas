#!/usr/bin/perl -w

use strict;
use List::Util qw(first); 
use Getopt::Std;

my $pvalColName = "PVAL";
my $chrColName = "CHR";
my $posColName = "POS";
my $rsidColName = "RSID";
my $windowSize = 5000;
my $pBorder = 5E-4; # always include better p values
my $transferColName = "MAF";

my %opts;
getopt('pcwlrht', \%opts);
$pvalColName = $opts{'p'} if exists $opts{'p'};
$chrColName = $opts{'c'} if exists $opts{'c'};
$posColName = $opts{'l'} if exists $opts{'l'};
$rsidColName = $opts{'r'} if exists $opts{'r'};
$windowSize = $opts{'w'} if exists $opts{'w'};
$transferColName = $opts{'t'} if exists $opts{'t'};

if (exists $opts{'h'}) {
  die "Usage: $0 -p pvalColName -c chrColName -l posColName -r rsidColName -w windowSizeBp -t transferColName";
}

my $currentRegionChr = -1;
my $currentRegionPos = -1;
my $currentRegionIdx = "";
my $currentRegionPval = -1;
my $currentRegionRsid = "";
my $currentRegionTransfer = "";

my $firstLine = <>;
chomp($firstLine);
my @header = split(/\t/, $firstLine);

my $pvalCol = first { $header[$_] eq $pvalColName } 0..$#header;
die "did not find PVAL column $pvalColName\n" unless defined $pvalCol;

my $chrCol = first { $header[$_] eq $chrColName } 0..$#header;
die "did not find CHR column $chrColName\n" unless defined $chrCol;

my $posCol = first { $header[$_] eq $posColName } 0..$#header;
die "did not find POS column $posColName\n" unless defined $posCol;

my $rsidCol = first { $header[$_] eq $rsidColName } 0..$#header;
die "did not find RSID column $rsidColName\n" unless defined $rsidCol;

my $transferCol = -1;
if ($transferColName ne "") {
  $transferCol = first { $header[$_] eq $transferColName } 0..$#header;
  die "did not find transfer column $transferColName\n" unless defined $transferCol;
}

print STDERR "Found PVAL column $pvalCol, CHR column $chrCol, POS column $posCol, RSID column $rsidCol\n";
print STDERR "Using window size $windowSize\n";
if ($transferColName ne "") {
  print STDERR "Transferring column $transferColName at column $transferCol\n";
}

print STDOUT "RSID\tCHR\tPOS\tPVAL";
if ($transferColName ne "") {
  print STDOUT "\t" . $transferColName;
}
print STDOUT "\n";

while (<>) {
  next if /^#/;
  my @line = split(/\t/);
  my $lineChr = $line[$chrCol];
  next if ($lineChr eq "CHR");
  my $linePos = $line[$posCol];
  chomp($linePos);
  my $linePval = $line[$pvalCol];
  my $lineRsid = $line[$rsidCol];
  my $lineIdx = $lineChr . "_" . int($linePos / $windowSize);
  my $lineTransfer = "";
  if ($transferCol > -1) {
    $lineTransfer = $line[$transferCol];
  }

  # region end?
  if (($currentRegionIdx ne "" && $currentRegionIdx ne $lineIdx) || $linePval < $pBorder) {
    print STDOUT $currentRegionRsid . "\t" . $currentRegionChr . "\t" . $currentRegionPos . "\t" . $currentRegionPval;
    if ($transferCol > -1) {
      print STDOUT "\t" . $currentRegionTransfer;
    }
    print STDOUT "\n";
    $currentRegionIdx = "";
  }

  # region start?
  if ($currentRegionIdx eq "") {
    $currentRegionChr = $lineChr;
    $currentRegionPos = $linePos;
    $currentRegionIdx = $lineIdx;
    $currentRegionPval = $linePval;
    $currentRegionRsid = $lineRsid;
    $currentRegionTransfer = $lineTransfer;
  } else {
    # line in current region; maybe update with better pval
    if ($linePval < $currentRegionPval) {
      $currentRegionPos = $linePos;
      $currentRegionPval = $linePval;
      $currentRegionRsid = $lineRsid;
      $currentRegionTransfer = $lineTransfer;
    }
  }
}

# last region
if ($currentRegionIdx ne "") {
  print STDOUT $currentRegionRsid . "\t" . $currentRegionChr . "\t" . $currentRegionPos . "\t" . $currentRegionPval;
  if ($transferCol > -1) {
    print STDOUT "\t" . $currentRegionTransfer;
  }
  print STDOUT "\n";
}

