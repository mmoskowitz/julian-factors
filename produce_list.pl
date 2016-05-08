#!/usr/bin/perl

push @INC, ".";
use Julian;
use strict;
my $input = shift;
my ($year, $month, $day) = $input =~ /(\d\d\d\d)-(\d\d)-(\d\d)/;
my $julian = Julian::convert_date($year, $month, $day);
my @factors = Julian::factor($julian);
my @searches = Julian::get_searches(join ",", @factors);
print join "\n", @searches;
#my $infoline = join "\t", ("~You", join("-", ($year,$month,$day)),$julian, (join ",", @factors));
#print $infoline."\n";
#&search_factors($infoline, (join ",", @factors));

