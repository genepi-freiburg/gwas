#!/usr/bin/perl -w
use strict;
use DBI;

die "Params: mantra_in mantra_out snp_file sqlite_db n_studies" if (@ARGV != 5);

my $MANTRA_IN = $ARGV[0];
my $MANTRA_OUT = $ARGV[1];
my $SNP_FILE = $ARGV[2];
my $SQLITE_FILE = $ARGV[3];
my $N_STUDIES = $ARGV[4];

print STDERR "SNP file = $SNP_FILE, SQLite = $SQLITE_FILE, N_STUDIES = $N_STUDIES, out = $MANTRA_OUT\n";

my @mantraIn = split("\n", `cat $MANTRA_IN`);
print STDERR "Mantra In = @mantraIn\n";

my $dbargs = {AutoCommit => 0, PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=$SQLITE_FILE", "", "", $dbargs);

$dbh->do("PRAGMA main.page_size = 4096; PRAGMA main.cache_size=10000; PRAGMA main.locking_mode=EXCLUSIVE; PRAGMA main.synchronous=NORMAL; PRAGMA main.journal_mode=WAL;");

# $dbh->do("create table gwas_hit (rsid varchar(60) not null, chr varchar(10) not null, ref varchar(90) not null, obs varchar(90) not null, pos int not null, gwas_ident varchar(60), sample_size int not null, allele_freq real, effect_beta real, effect_std_err real, primary key (rsid, gwas_ident));");

my $sth = $dbh->prepare("SELECT * FROM gwas_hit WHERE rsid = ? AND chr = ? AND ref = ? AND obs = ? AND pos = ? ORDER BY gwas_ident");

my $counter = 0;
my $skip = 0;
print STDERR "SNP count: 0";

open(LF, $SNP_FILE) or die "Unable to open SNP file $SNP_FILE\n";
open(OUT, ">$MANTRA_OUT") or die "Unable to open output file $MANTRA_OUT\n";

while(<LF>) {
	my $line = $_;
        my @mapl = split(/\t/, $line);
	my $snp = $mapl[0];
	my $chr = $mapl[1];
	my $pos = $mapl[2];
	my $all1 = $mapl[3];
	my $all2 = $mapl[4];
	chomp($all2);

	$counter++;
	$sth->bind_param(1, $snp);
	$sth->bind_param(2, $chr);
	$sth->bind_param(3, $all1);
	$sth->bind_param(4, $all2);
	$sth->bind_param(5, $pos);
	$sth->execute();

	my $rows = $sth->fetchall_arrayref();
	my $numRows = 0 + @$rows;

	if ($numRows >= $N_STUDIES) {
		print OUT $line;
		foreach my $mantraIn (@mantraIn) {
			$mantraIn =~ s/\.gwas//g;
			my $found = 0;
			foreach my $row (@$rows) {
				if (${$row}[5] eq $mantraIn) {
					$found = 1;
					print OUT "1 ${$row}[6] ${$row}[7] ${$row}[8] ${$row}[9]\n";
				}
			} 
			if (!$found) {
				print OUT "0 0 0 0 0\n";
			}
		}
	} else {
		$skip++;
	}

	if ($counter % 100 == 0) {
		print STDERR "\rSNP count: $counter";
	}
}

close(LF);
close(OUT);

print STDERR "\nFinished reading files\n";
print STDERR "Skipped $skip SNPs because of study count filter\n";

$sth->finish();
$dbh->disconnect();
