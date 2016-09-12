#!/usr/bin/perl

package Julian;

use strict;

our $VERSION = '1.00';

our @EXPORT = qw(convert_date factor get_filename get_searches);

our @primes;

sub get_primes{
    if (@primes == 0){
	open IN, "primes.txt";
	while (my $prime = <IN>){
	    #print "P:$prime\n";
	    chomp $prime;
	    #print "A:$prime\n";
	    push @primes, int($prime);
	}
    }
    return @primes;
}

sub convert_date{
    my ($year, $month, $day);
    $year = shift;
    if ($year < 0){
	$year++;
    }
    $month = shift;
    $day = shift;
    if ($year > 1582 || ($year == 1582 && $month >= 10)){
	return &convert_gregorian($year, $month, $day);
    } elsif ($year > -46) {
	return &convert_julian($year, $month, $day);
    } else {
	return 1;
    }
}

sub convert_julian{
    my ($year, $month, $day);
    $year = shift;
    $month = shift;
    $day = shift;
    #from xslt cookbook:
    my $a = int((14 - $month)/12);
    my $y = $year + 4800 - $a;
    my $m = $month + 12 * $a - 3;
    my $jd = $day 
	+ int((153 * $m + 2)/5) 
	+ $y * 365 
	+ int($y/4) 
	- 32083;
    return $jd;
}

sub convert_gregorian{
    my ($year, $month, $day);
    $year = shift;
    $month = shift;
    $day = shift;
    #from xslt cookbook:
    my $a = int((14 - $month)/12);
    my $y = $year + 4800 - $a;
    my $m = $month + 12 * $a - 3;
    my $jd = $day 
	+ int((153 * $m + 2)/5) 
	+ $y * 365 
	+ int($y/4) 
	- int($y/100) 
	+ int($y/400)
	- 32045;
    return $jd;
}

sub factor{
    my $number = shift;
    my @factors;
    my $current_index = 0;
    my @primes = &get_primes();
    my $current = $primes[$current_index];
    while ($number >= $current**2){
	if ($number % $current == 0){
	    push @factors, $current;
	    $number /= $current;
	} else {
	    $current_index++; 
	    $current = $primes[$current_index];
	}
    } 
    push @factors, $number;
    return @factors;
}

sub get_filename{
    my $factoring = shift;
    my $data_dir = shift;
    my $tempfactor = (split ":", $factoring)[0];
    my $dir = substr $tempfactor, -2;
    if (length($dir) == 1) {
	$dir = "0$dir";
    }
    my $filename = "$data_dir/$dir/$factoring.txt";
    $filename =~ s|//|/|;
    $filename =~ s|:|_|;
    $filename =~ s|/ME/|/|;

    return $filename;
}

sub get_searches{
    my $factorization = shift;
    my @factors = split ",", $factorization;
    my %searches;
    #use binary numbers to get all combinations
    for (my $n = 2**@factors -1; $n > 0; $n--){ #all combinations except 0;
	my $tempfactor = 1;
	my $factorsleft = @factors;
	for (my $i = 0; $i < @factors; $i++){
	    if (2**$i & $n){
		$tempfactor *= $factors[$i];
		$factorsleft--;
	    }
	}
	if ($tempfactor < 100000){ #an arbitrary cutoff
	    my $search = "$tempfactor:$factorsleft";
	    if (!$searches{$search}){
		$searches{$search} = 1;
	    }
	}
    }
    if (1 == @factors){ #handle primes
	my $index_factorization = shift;
	my @index_factors;
	if ($index_factorization && $index_factorization > 0){
	    @index_factors  = split(',', $index_factorization);
	} else {
	    my $prime_index = &prime_index($factors[0]);
	    @index_factors = &factor($prime_index);
	}
	if (1 == @index_factors){
	    $searches{"P:PRIME"} = 1;
	    #print "$prime_index P:PRIME\n";
	} else {
	    #print "P:COMPOSITE\n";
	    for (my $n = 2**@index_factors -1; $n > 0; $n--){ #all combinations except 0;
		my $tempfactor = 1;
		my $factorsleft = @index_factors;
		for (my $i = 0; $i < @index_factors; $i++){
		    if (2**$i & $n){
			$tempfactor *= $index_factors[$i];
			$factorsleft--;
		    }
		}
		my $search = "P:$tempfactor";
		if (!$searches{$search}){
		    $searches{$search} = 1;
		}
	    }
	}
    }
    return sort keys %searches;
}

sub prime_index {
    my $prime = shift;
    #print "$prime\n";
    my @primes = &get_primes();
    my $low = 0;
    my $high = @primes - 1;

    while ( $low <= $high ) {
        my $try = int( ($low+$high) / 2 );
	my $trying = $primes[$try];
	#print "$low $try $high $trying $prime\n";
        $low  = $try+1, next if $trying < $prime;
        $high = $try-1, next if $trying > $prime;
        return $try + 1; #one-based
    }
    return; 
}

1;
