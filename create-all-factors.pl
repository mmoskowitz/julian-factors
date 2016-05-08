#!/usr/bin/perl

#reads in dates.tsv and creates a list of all factors, not just the prime ones.

my $file = shift;
open IN, $file;
my $count;
while (my $line = <IN>){
    #last if ($count > 20);
    my ($name, $date, $julian, $factorization) = split /\t/, $line;
    my $infoline = join(", ", ($name, $date, $factorization));
    #print $infoline;
    &print_factors($infoline, $factorization);
    $count++;
}

sub print_factors{
    my $infoline = shift;
    my $factorization = shift;
    my @factors = split ",", $factorization;
    #use binary numbers to get all combinations
    for ($n = 1; $n < 2**@factors; $n++){ #all combinations except 0;
	#print $n . "\n";
	my $tempfactor = 1;
	my $factorsleft = @factors;
	for ($i = 0; $i < @factors; $i++){
	    if (2**$i & $n){
		$tempfactor *= $factors[$i];
		$factorsleft--;
	    }
	}
	print join "\t", ($tempfactor, $factorsleft, $infoline);
	print "\n";
	if (1 == @factors){
	    print "PRIME\t$infoline\n";
	}
    }
}
