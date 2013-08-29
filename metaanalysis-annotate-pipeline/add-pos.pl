#!/usr/bin/perl -w

# TODO extract to params file
my $legend_files = "/data/gwas/pediGFR_gwas/Metaanalysis/Imputed/map/*.legend";

use strict;

my $i = 0;
my @header;
while(<>) {
	my @fields = split(/\t/);
	if ($i > 0) {
		my $rsid = $fields[0];
		my $cmd = "grep '$rsid ' $legend_files";
		my $mapline = `$cmd`;
		my $chr = "?", my $pos = "?", my $ref = "?", my $obs = "?";
		if ($mapline =~ /_chr(\d+)_/) {
			$chr = $1;
			my @mapl = split(/ /, $mapline);
			$pos = $mapl[1];
			$ref = $mapl[3];
			$obs = $mapl[2];
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
