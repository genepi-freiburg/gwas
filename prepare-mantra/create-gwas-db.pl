#!/usr/bin/perl -w
use strict;
use DBI;

my $DATA_DIR = $ARGV[0];
print STDERR "data dir = $DATA_DIR\n";

my $dbargs = {AutoCommit => 0, PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=$DATA_DIR/gwas.sqlite", "", "", $dbargs);

print STDERR "pragmas\n";
$dbh->do("PRAGMA main.page_size = 4096; PRAGMA main.cache_size=10000; PRAGMA main.locking_mode=EXCLUSIVE; PRAGMA main.synchronous=NORMAL; PRAGMA main.journal_mode=WAL;");

print STDERR "create table\n";
$dbh->do("create table gwas_hit (rsid varchar(60) not null, chr varchar(10) not null, ref varchar(90) not null, obs varchar(90) not null, pos int not null, gwas_ident varchar(60), sample_size int not null, allele_freq real, effect_beta real, effect_std_err real, primary key (rsid, gwas_ident));");

my $sth = $dbh->prepare("insert into gwas_hit (rsid, chr, ref, obs, pos, gwas_ident, sample_size, allele_freq, effect_beta, effect_std_err) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);");

foreach my $argnum (1 .. $#ARGV) {
	my $gwas_fn = $ARGV[$argnum];
	my $gwas_id = `basename $gwas_fn`;
	$gwas_id =~ s/\.gwas//g;
	chomp($gwas_id);
	print STDERR "process $gwas_id; fn = $gwas_fn\n";
	my $counter = 0;
	print STDERR "read SNPs...";

	open(LF, $gwas_fn) or die "Unable to open GWAS file $gwas_fn\n";
	while(<LF>) {
		my $line = $_;
                my @mapl = split(/\t/, $line);
		my $snp = $mapl[0];
		if ($snp ne "SNP") {
				#skip header
				$counter++;
				$sth->bind_param(1, $snp);
				$sth->bind_param(2, $mapl[1]);
				$sth->bind_param(3, $mapl[3]);
				$sth->bind_param(4, $mapl[4]);
				$sth->bind_param(5, $mapl[2]);
				$sth->bind_param(6, $gwas_id);
				$sth->bind_param(7, $mapl[12]);
				$sth->bind_param(8, $mapl[9]);
				$sth->bind_param(9, $mapl[6]);
				$sth->bind_param(10, $mapl[7]);
				$sth->execute();
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
print STDERR "\nFinished reading files\n";

$dbh->do("commit transaction;");
$sth->finish();
$dbh->disconnect();
