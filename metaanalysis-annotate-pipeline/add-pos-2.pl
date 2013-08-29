#!/usr/bin/perl -w
use strict;

# TODO extract to params file
my $legend_files = "/data/gwas/pediGFR_gwas/Metaanalysis/Imputed/map/*.legend";
my %snps;
my $legend_file_names = `ls $legend_files -1`;
my $counter = 0;
foreach my $legend_file_name (split(/\n/, $legend_file_names)) {
	print STDERR "read legend file $legend_file_name\n";
	open(LF, $legend_file_name) or die "Unable to open legend file $legend_file_name\n";
	while(<LF>) {
		my $line = $_;
		if ($legend_file_name =~ /_chr(\d+)_/) {
                        my $chr = $1;
                        my @mapl = split(/ /, $line);
			my $snp = $mapl[0];
                        my $pos = $mapl[1];
                        my $ref = $mapl[3];
                        my $obs = $mapl[2];
			if ($snp ne "id") {
				#skip header
				$snps{$snp} = "$chr $pos $ref $obs";
				$counter++;
			}
                }

	}
	close(LF);
}
print STDERR "Finished reading legend files; collected $counter SNPs\n";


my $i = 0;
my @header;
while(<>) {
	my @fields = split(/\t/);
	if ($i > 0) {
		my $rsid = $fields[0];
		my $res = $snps{$rsid};
		my $chr = "?", my $pos = "?", my $ref = "?", my $obs = "?";
		if ($res) {
			my @mapl = split(/ /, $res);
			$chr = $mapl[0];
			$pos = $mapl[1];
			$ref = $mapl[2];
			$obs = $mapl[3];
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
print STDERR "Finished; processed $i lines\n";
