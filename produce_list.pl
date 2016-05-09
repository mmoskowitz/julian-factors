#!/usr/bin/perl

push @INC, ".";
use Julian;
use strict;
my $input = shift;

my $searchfile = "source_data/factors_trimmed_sorted_unique.tsv";
my $data_dir = "output-data";

my ($year, $month, $day) = $input =~ /(\d\d\d\d)-(\d\d)-(\d\d)/;
my $julian = Julian::convert_date($year, $month, $day);
my @factors = Julian::factor($julian);
my @searches = Julian::get_searches(join ",", @factors);
my %results = {};
foreach my $search (sort {$b <=> $a} @searches) {
    print $search."\n";
    my @results;
    my $filename = Julian::get_filename($search, $data_dir);
    open IN, $filename;
    @results = <IN>;
    close IN;
    print @results;
}

#print join "\n", @searches;

#my $infoline = join "\t", ("~You", join("-", ($year,$month,$day)),$julian, (join ",", @factors));
#print $infoline."\n";
#&search_factors($infoline, (join ",", @factors));

