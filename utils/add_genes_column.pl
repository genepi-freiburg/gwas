#!/usr/bin/perl -w

use DBI;
use List::Util qw(min max);
use strict;

my $annofile = $ARGV[0] or die "Usage: $0 AnnovarFile\n";
my $outfile = $annofile . ".added";
my $extend = 500000;

my $db = "hg19";
my $host = "genome-mysql.cse.ucsc.edu";
my $user = "genome";

my $dbh = DBI->connect("dbi:mysql:$db;host=$host", $user, "",
    {RaiseError => 1}) or die $DBI::errstr;
my $sth = $dbh->prepare("select geneName, chrom, min(txStart), max(txEnd) from
    refFlat where substr(chrom, 4) = ? and not(?+$extend < txStart or
    ?-$extend > txEnd) group by geneName, chrom");

open(ANNO, $annofile) or die "Cannot open Annovar file!\n";
open(OUT, ">" . $outfile) or die "Cannot open out file to write!\n";

while (<ANNO>) {
    my $line = $_;
    if ($line =~ /^Chr/i) {
        print OUT $line;
        next;
    }

    chomp($line);
    my @line_arr = split(/\t/, $line);
    my $chr = $line_arr[0];
    my $pos = $line_arr[1];

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

$sth->finish();
$dbh->disconnect();
