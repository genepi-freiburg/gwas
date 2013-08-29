#!/usr/bin/perl -w

use strict;

my $i = 0;
my @header;
while(<>) {
	my @fields = split(/\t/);
	if ($i > 0) {
		my $rsid = $fields[0];
		my $cmd = "grep '$rsid ' ../map/*.legend";
		my $mapline = `$cmd`;
		my $chr = "?", my $pos = "?", my $ref = "?", my $obs = "?";
		if ($mapline =~ /_chr(\d+)_/) {
			$chr = $1;
			my @mapl = split(/ /, $mapline);
			$pos = $mapl[1];
			$ref = $mapl[3];
			$obs = $mapl[2];
		} else {
			# try strand file for kgp SNPs
			$cmd = "grep '$rsid\t' ../map/HumanOmni2.5-8v1_A-b37.strand";
			$mapline = `$cmd`;
			my @mapl = split(/\t/, $mapline);
			if ($#mapl > 2) {
				$chr = $mapl[1];
				$pos = $mapl[2];
				$ref = substr($mapl[5],1,1);
				$obs = substr($mapl[5],0,1);
			}
		}
		my $pos2;
		if ("$pos" ne "?") {
			$pos2 = $pos + length($ref) - 1;
		} else {
			$pos2 = "?";
		}
		print("$chr\t$pos\t$pos2\t$ref\t$obs\t" . join("\t", @fields));
	} else {
		@header = @fields;
		print("CHR\tSTART\tEND\tREF\tOBS\t" . join("\t", @header));
	}
	$i++;
}
