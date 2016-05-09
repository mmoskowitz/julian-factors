#!/usr/bin/perl

package Julian;

use strict;

our $VERSION = '1.00';

our @EXPORT = qw(convert_date factor get_filename);

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

sub sort_searches {
    my @a = split ":", $a;
    my @b = split ":", $b;
    my $first = ($a[0] <=> $b[0]);
    return $first == 0? $a[1] <=> $b[1] : $first;
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
