#! /usr/bin/perl

#generates a list of prime numbers.
my $count = shift;
my @primes = (2);
my $candidate = 3;
MAIN: while (@primes < $count){
    for (my $i = 0; $primes[$i] * $primes[$i] <= $candidate; $i++){
	if ($candidate % $primes[$i] == 0){
	    $candidate++;
	    next MAIN;
	}
    }
    push @primes, $candidate;
    $candidate++;
}

print join "\n", @primes;

