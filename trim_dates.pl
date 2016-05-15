#!/usr/bin/perl

use strict;

my $pantheon_file = shift;
my $dates_file = shift;

open IN, $pantheon_file;
my $head = <IN>;
my %names;
my %view_counts;
#populate names
while (my $line = <IN>){
    my @fields = split /\t/, $line;
    my $name = $fields[1];
    my $year = $fields[11];
    my $view_count = $fields[21];
    $names{$name} = $year;
    $view_counts{$name} = $view_count;
}
close IN;

open IN, $dates_file;
while (my $line = <IN>){
    chomp $line;
    my ($name, $year) = ($line =~ /^(.*)\s(-?\d\d\d\d)-\d\d-\d\d\s/);
    $name =~ s/_\(.*\)//;
    $name =~ s/_/ /g;
    $name =~ s/%22//g;
    if ($names{$name} == $year){
	$line .= "\t$view_counts{$name}";
	$line =~ s/\t\t/\t/;
	print "$line\n";
    }
}
