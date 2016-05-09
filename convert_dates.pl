#!/usr/bin/perl

push @INC, ".";
use Julian;
use strict;
my $input = shift;

my $searchfile = "source_data/factors_trimmed_sorted_unique.tsv"

if (my ($year, $month, $day) = $input =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
    my $julian = Julian::convert_date($year, $month, $day);
    my @factors = Julian::factor($julian);
    my $infoline = join "\t", ("~You", join("-", ($year,$month,$day)),$julian, (join ",", @factors));
    &search_factors($infoline, (join ",", @factors));
} else {
    &parse_file($input);
}

sub parse_file{
    my $file = shift;
    open IN, $file;
    
    my $count = 0;
    
    while (my $line = <IN>){
	#last if ($count > 200);
	my ($name, $year, $month, $day) = 
	    ($line =~ 
	     m%resource/(.*)> <http:.*birthDate>\s"(-?\d\d\d\d)-(\d\d)-(\d\d)"%); 
	next unless ($name);
	next if ($year < 1583); 
	my $julian = Julian::convert_date($year, $month, $day);
	my @factors = Julian::factor($julian);
	print join "\t", ($name, join("-", ($year,$month,$day)),$julian, (join ",", @factors)), "\n";
	$count++;
    }
}

sub search_factors{
    my $infoline = shift;
    my $factorization = shift;
    my @factors = split ",", $factorization;
    my %searches_done;
    #use binary numbers to get all combinations
    for (my $n = 2**@factors -1; $n > 0; $n--){ #all combinations except 0;
	#print $n . "\n";
	my $tempfactor = 1;
	my $factorsleft = @factors;
	for (my $i = 0; $i < @factors; $i++){
	    if (2**$i & $n){
		$tempfactor *= $factors[$i];
		$factorsleft--;
	    }
	}
	print join "\t", ($tempfactor, $factorsleft, $infoline, "\n");
	my $search = "grep '^$tempfactor\\s$factorsleft\\s' $searchfile";
	if (!$searches_done{$search}){
	    my @results = qx"$search";
	    print @results;
	    $searches_done{$search} = 1;
	}
	if (1 == @factors){
	    print "PRIME\t$infoline\n";
	}
    }
}
