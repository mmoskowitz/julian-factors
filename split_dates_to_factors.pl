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
    #last if ($count > 20);
    my ($name, $date, $julian, $factorization) = split /\t/, $line;
    my $infoline = join(", ", ($name, $date, $factorization));
    #print $infoline;
    add_factors($infoline, $factorization);
    $count++;
}

foreach my $factoring (sort keys %factors){
    next if ($factoring =~ /:0$/);
    
    my $filename = Julian::get_filename($factoring, $output_dir);

    #my $tempfactor = (split ":", $factor)[0];
    #my $dir = substr $tempfactor, -2;
    #if (length($dir) == 1) {
	#$dir = "0$dir";
    #}
    #$filename =~ s|//|/|;
    #$filename =~ s|/ME/|/|;
    #$filename =~ s|:|_|;
    open OUT, ">", "$filename" || die "can't write $filename\n";
    print "writing $filename\n";
    my @results = sort @{$factors{$factoring}};
    for (my $i = 0; $i < @results; $i++){
	if ($results[$i] ne $results[$i+1]){
	    print OUT $results[$i]."\n";
	}
    }
    close OUT;
}



#print join "\n", keys %factors;


sub add_factors{
    my $infoline = shift;
    my $factorization = shift;
    my @factors = split ",", $factorization;
    #use binary numbers to get all combinations
    for (my $n = 1; $n < 2**@factors; $n++){ #all combinations except 0;
	#print $n . "\n";
	my $tempfactor = 1;
	my $factorsleft = @factors;
	for (my $i = 0; $i < @factors; $i++){
	    if (2**$i & $n){
		$tempfactor *= $factors[$i];
		$factorsleft--;
	    }
	}
	&add_factor ("$tempfactor:$factorsleft", $infoline);
	if (1 == @factors){
	    &add_factor("PRIME", $infoline);
	}
    }
}

sub add_factor{
    my $search = shift;
    my $infoline = shift;
    if (!($factors{$search})) {
	$factors{$search} = [];
    }
    push @{$factors{$search}}, $infoline;
}
