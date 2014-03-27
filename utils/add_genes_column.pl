#!/usr/bin/perl -w

use DBI;
use List::Util qw(min max);
use strict;

my $annofile = $ARGV[0] or die "Usage: $0 AnnovarFile <chrCol> <posCol>\n";
my $outfile = $annofile . ".added";
my $extend = 500000;

my $db = "hg19";
my $host = "genome-mysql.cse.ucsc.edu";
my $user = "genome";

print("Connect to $host\n");

my $dbh = DBI->connect("dbi:mysql:$db;host=$host", $user, "",
    {RaiseError => 1}) or die $DBI::errstr;
my $sth = $dbh->prepare("select geneName, chrom, min(txStart), max(txEnd) from
    refFlat where substr(chrom, 4) = ? and not(?+$extend < txStart or
    ?-$extend > txEnd) group by geneName, chrom");

open(ANNO, $annofile) or die "Cannot open Annovar file!\n";
open(OUT, ">" . $outfile) or die "Cannot open out file to write!\n";

my $chrCol = 0;
my $posCol = 1;
if ($#ARGV > 1) {
	$chrCol = $ARGV[1];
	$posCol = $ARGV[2];
	print("Using chromosome column $chrCol and position column $posCol from cmdline\n");
}

my $lc = 0;
while (<ANNO>) {
    my $line = $_;
    chomp($line);

    $lc = $lc + 1;
    if ($lc == 1) { 
	# header
	print("Add header line\n");
        print OUT $line . "\tgene_intron\tgenes_regional\n";
        next;
    }

    print("Process line $lc\n");

    my @line_arr = split(/\t/, $line);
    my $chr = $line_arr[$chrCol];
    my $pos = $line_arr[$posCol];

    $sth->execute($chr, $pos, $pos);

    my (@ingene, @added, %added);
    while (my @ary = $sth->fetchrow_array()) {
        if ($pos >= $ary[2] and $pos <= $ary[3]) {
            push(@ingene, $ary[0]);
        } else {
            $added{$ary[0]} = $pos>$ary[3] ? $pos-$ary[3] :
                $ary[2]-$pos+1;
        }
    }
    foreach my $key (sort {$added{$a} <=> $added{$b}} keys %added) {
        push(@added, $key . "(dist=" . $added{$key} . ")");
    }
    print OUT $line . "\t". join(",",@ingene)."\t".join(",", @added) ."\n";
    # print join(",", @added) . "\n";
}
close(OUT);
close(ANNO);
print("\nFinished.\n");

$sth->finish();
$dbh->disconnect();
