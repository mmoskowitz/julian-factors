#!/usr/bin/perl

#reads in dates.tsv and creates a list of all factors, not just the prime ones.
push @INC, ".";
use Julian;
use strict;

my $file = shift;
my $output_dir = shift;
open IN, $file;
my $count;
my %factors;
while (my $line = <IN>){
    #last if ($count > 2000);
    my ($name, $date, $julian, $factorization, $viewcount) = split /\t/, $line;
    my $infoline = join(", ", ($name, $date, $factorization, $viewcount));
    #print $infoline;
    add_factors($infoline, $factorization);
    $count++;
}

foreach my $factoring (sort keys %factors){
    next if ($factoring =~ /:0$/);
    
    my $filename = Julian::get_filename($factoring, $output_dir);
    open OUT, ">", "$filename" || die "can't write $filename\n";
    print "writing $filename\n";
    #get top 20 by pageviews
    my @results_by_view = sort {(split ", ", $b)[3] <=> (split ", ", $a)[3]} uniq(@{$factors{$factoring}});
    my @results_filtered = @results_by_view[0..20];
    my @results = sort @results_filtered;
    for (my $i = 0; $i < @results; $i++){
	if ($results[$i] ne $results[$i+1]){
	    print OUT $results[$i];
	}
    }
    close OUT;
}



#print join "\n", keys %factors;


sub add_factors{
    my $infoline = shift;
    my $factorization = shift;
    my @searches = Julian::get_searches($factorization);
    foreach my $search (@searches){
	&add_factor($search, $infoline);
    }
}

#from http://stackoverflow.com/questions/7651/how-do-i-remove-duplicate-items-from-an-array-in-perl
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

sub add_factor{
    my $search = shift;
    my $infoline = shift;
    my $name = (split ", ", $infoline)[0];
    if (!($factors{$search})) {
	$factors{$search} = [];
    }
    push @{$factors{$search}}, $infoline;
}
