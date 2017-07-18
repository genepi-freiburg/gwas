#open(FAM, "<".$ARGV[1]) or die "Unable to open FAM file: $ARGV[1]\n";
#my @fam;
#print "Processing FAM file $ARGV[1]\n";
#while(<FAM>) {
# my @fields = split / +/;
# push @fam, $fields[1];
#}
#close(FAM);
#print "Got " . ($#fam+1) . " FAM entries\n";

my %counts, %sums, $i;

open(GENOME, "<".$ARGV[0]) or die "Unable to open genome file: $ARGV[0]\n";
open(AVGDST, ">".$ARGV[1]) or die "Unable to open output file: $ARGV[2]\n";
print AVGDST "IID\tAVGDST\n";

print "Processing Genome file $ARGV[0]\n";
while (<GENOME>) {
 my @fields = split / +/;
 if ($fields[1] != "IID1") {
   my $iid1 = $fields[1];
   my $iid2 = $fields[3];
   my $dst = $fields[12];
   $counts{$iid1} = $counts{$iid1} + 1;
   $counts{$iid2} = $counts{$iid2} + 1;
   $sums{$iid1} = $sums{$iid1} + $dst;
   $sums{$iid2} = $sums{$iid2} + $dst;
   $i = $i + 1;
 }
}
close(GENOME);
print "Processed " . $i . " DST entries for " . scalar(keys(%counts)) . " individuals\n";


print "Writing average DST file $ARGV[1]\n";
foreach my $ind (sort(keys(%counts))) {
  # print "Process $ind\n";
  my $avgdst = $sums{$ind} / $counts{$ind};
  print AVGDST "$ind\t" . $avgdst . "\n";
}
print "Finished\n";
close(AVGDST);
