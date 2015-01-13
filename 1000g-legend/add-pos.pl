#!/usr/bin/perl
use strict;
use DBI;
# reads a RSID from the given column and adds position information as new columns

# needs a "legend" DB
my $dbn = "/data/gwas/pediGFR_gwas/Metaanalysis/Imputed/map/ALL_1000G.sqlite";
die "sqlite DB not found" if ! -f $dbn;

# reads data from STDIN and writes to STDOUT
my $rsidx = 0;
print STDERR "Using legend DB: $dbn\nRSID column: $rsidx\n";

# db
my $dbargs = {AutoCommit => 0, PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbn", "", "", $dbargs);
my $sth = $dbh->prepare("SELECT chr, pos FROM snps WHERE rsid = ?");

# lookup function
sub lookup
{
	my $snp = shift;
	$sth->execute($snp);
	my @row = $sth->fetchrow_array();
	if (!@row) {
		@row = ("CHR","POS");
	}
	return @row;
}

# main program
while (<>) {
	my @fields = split(/[\t ]/);
	chomp($fields[$#fields]);
	my @pos = lookup($fields[$rsidx]);
	push(@fields, @pos);
	print(join("\t", @fields)."\n");
}
