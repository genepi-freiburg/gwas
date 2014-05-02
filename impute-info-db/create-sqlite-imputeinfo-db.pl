#!/usr/bin/perl -w
use strict;
use DBI;

my $dbargs = {AutoCommit => 0, PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=ImputeInfo.sqlite", "", "", $dbargs);

print STDERR "pragmas\n";
$dbh->do("PRAGMA main.page_size = 4096; PRAGMA main.cache_size=10000; PRAGMA main.locking_mode=EXCLUSIVE; PRAGMA main.synchronous=NORMAL; PRAGMA main.journal_mode=WAL;");

print STDERR "create table\n";
$dbh->do("create table if not exists imputeinfo ( rsid varchar(60) not null, study varchar(60) not null, is_imputed int not null, info numeric null, concordance numeric null, primary key (rsid, study));");

$dbh->do("create index if not exists snpidx on imputeinfo (rsid)");

my $sth = $dbh->prepare("insert into imputeinfo values (?, ?, ?, ?, ?);");

my $grp = $ARGV[0];
my $fn = $ARGV[1];
print STDERR "parse impute2_info file $fn (group $grp)\n";

open(LF, $fn) or die "Unable to open file $fn\n";
my $counter = 0;
while(<LF>) {
#snp_id rs_id position exp_freq_a1 info certainty type info_type0 concord_type0 r2_type0
	my $line = $_;
        my @mapl = split(/ /, $line);
	my $snp = $mapl[0];
        my $rs = $mapl[1];
        my $info = $mapl[4];
        my $concord = $mapl[8];
	if ($snp ne "snp_id") {
		#skip header
		$counter++;
		$sth->bind_param(1, $rs);
		$sth->bind_param(2, $grp);
		if ($concord > -1) {
			$sth->bind_param(3, 0);
		} else {
			$sth->bind_param(3, 1);
		}
		$sth->bind_param(4, $info);
		$sth->bind_param(5, $concord);
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
print STDERR "\nFinished reading legend files; collected $counter SNPs\n";

$dbh->do("commit transaction;");
$sth->finish();
$dbh->disconnect();
