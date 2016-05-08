#!/usr/bin/perl

package Julian;

use strict;

our $VERSION = '1.00';

our @EXPORT = qw(convert_date factor);

sub convert_date{
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
	- 32046; #subtracted one more day to match naval obs 
    return $jd;
}

sub factor{
    my $number = shift;
    my @factors;
    my $current = 2;
    while ($number > $current**2){
	if ($number % $current == 0){
	    push @factors, $current;
	    $number /= $current;
	} else {
	    $current++; #inefficient, whatever
	}
    } 
    push @factors, $number;
    return @factors;
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
	if ($tempfactor < 100000){
	    my $search = "$tempfactor:$factorsleft";
	    if (!$searches{$search}){
		$searches{$search} = 1;
	    }
	}
	if (1 == @factors){
	    $searches{"PRIME"} = 1;
	}
    }
    return sort keys %searches;
}

1;