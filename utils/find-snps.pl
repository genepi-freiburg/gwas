#!/usr/bin/perl -w

use strict;
my $fn = $ARGV[0];

print STDERR "candidate file: $fn\n";
my @candidates = split('\n', `cat $fn`);
my $n = $#candidates + 1;
print STDERR "got $n candidate SNPs: @candidates\n";

my $i = 0;
my $found = 0;
while(<STDIN>) {
	my @fields = split(/\t/);
	if ($i > 0) {
		my $snp = $fields[0];
		if (grep(/^$snp$/, @candidates)) {
			print(join("\t",@fields));
			$found++;
		}
	}
	$i++;
	if ($i % 1000 == 0) {
		print STDERR "Processing line $i\r";
	}
}

print STDERR "\nfound $found SNPs in output, processed $i lines\n";
