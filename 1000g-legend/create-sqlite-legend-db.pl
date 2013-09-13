#!/usr/bin/perl -w
use strict;
use DBI;

`rm -f ALL_1000G.sqlite*`;
my $dbargs = {AutoCommit => 0, PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=ALL_1000G.sqlite", "", "", $dbargs);

print STDERR "pragmas\n";
$dbh->do("PRAGMA main.page_size = 4096; PRAGMA main.cache_size=10000; PRAGMA main.locking_mode=EXCLUSIVE; PRAGMA main.synchronous=NORMAL; PRAGMA main.journal_mode=WAL;");

print STDERR "create table\n";
$dbh->do("create table snps ( rsid varchar(60) primary key not null, chr varchar(10) not null, ref varchar(60) not null, obs varchar(60) not null, pos int not null);");


my $sth = $dbh->prepare("insert into snps (rsid, chr, ref, obs, pos) values (?, ?, ?, ?, ?);");

my $legend_files = "/data/gwas/pediGFR_gwas/Metaanalysis/Imputed/map/*.legend";
my %snps;
my $legend_file_names = `ls $legend_files -1`;
my $counter = 0;
foreach my $legend_file_name (split(/\n/, $legend_file_names)) {
	print STDERR "\nread legend file $legend_file_name\n";
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
				$counter++;
				$sth->bind_param(1, $snp);
				$sth->bind_param(2, $chr);
				$sth->bind_param(3, $ref);
				$sth->bind_param(4, $obs);
				$sth->bind_param(5, $pos);
				$sth->execute();
			}
                }
		if ($counter % 100 == 0) {
			print STDERR "\rSNP count: $counter";
		}
		if ($counter % 10000 == 0) {
			$dbh->do("commit transaction;");
			$dbh->do("begin transaction;");
		}
	}
	close(LF);
}
print STDERR "\nFinished reading legend files; collected $counter SNPs\n";

$dbh->do("commit transaction;");
$sth->finish();
$dbh->disconnect();
