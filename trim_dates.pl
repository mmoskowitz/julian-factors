#!/usr/bin/perl

use strict;

my $pantheon_file = shift;
my $dates_file = shift;

open IN, $pantheon_file;
my $head = <IN>;
my %names;
#populate names
while (my $line = <IN>){
    my @fields = split /\t/, $line;
    my $name = $fields[1];
    my $year = $fields[11];
    $names{$name} = $year;
}
close IN;

open IN, $dates_file;
while (my $line = <IN>){
    my ($name, $year) = ($line =~ /^(.*)\s(-?\d\d\d\d)-\d\d-\d\d\s/);
    $name =~ s/_\(.*\)//;
    $name =~ s/_/ /g;
    $name =~ s/%22//g;
    if ($names{$name} == $year){
	print $line;
    }
}
