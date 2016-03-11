#!/usr/bin/perl -w

use strict;

my $p_border = $ENV{"P_BORDER"};
if (!$p_border) {
	$p_border = 1E-4;
}

my $hwe_border = $ENV{"HWE_BORDER"};
if (!$hwe_border) {
	$hwe_border = 1E-5;
}

my $maf_border = $ENV{"MAF_BORDER"};
if (!$maf_border) {
	$maf_border = 0.01;
}

print STDERR "p-border = $p_border, hwe-border = $hwe_border, maf-border $maf_border\n";

my $i = 0;
while(<>) {
	my @fields = split(/\t/);
	if ($i > 0) {
		my $omit = 0;
		if($fields[8] ne "NA" && $fields[8] < $p_border) {
			if ($#fields > 16) {
				# have cases/controls hwe
				if ($fields[17] < $hwe_border) {
					$omit = 1;
				}
			} else {
				# have only overall hwe
				if ($fields[10] < $hwe_border) {
					$omit = 1;
				}
			}
			my $af = $fields[9]; 
			if ($af < $maf_border || $af > 1-$maf_border) {
				$omit = 1;
			}
			if ($omit == 0) {
				print(join("\t",@fields));
			}
		}
	}
	$i++;
}
