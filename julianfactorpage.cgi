#!/usr/bin/perl

push @INC, ".";
use Julian;
use strict;
use CGI;
use DateTime;



my $q = CGI->new;
print $q->header(-type=>'text/html', -charset=>'utf-8');

my $year = int($q->param('year'));
my $month = int($q->param('month'));
my $day = int($q->param('day'));

my $dev = $q->param('dev'); #do something better

my $data_dir;
my $html_file;
if ($dev){
    #dev
    $data_dir = "output-data";
    $html_file = "index.html";
} else {
    #live
    $data_dir = "/home/marc/public_html/math/julian/output-data";
    $html_file = "/home/marc/public_html/math/julian/index.html";
}

my $preform = "";
my $results_text = "";

#print "hey $year $month $day\n";

#check inputs
if ($year < -46 || $month > 12 || $day > 31 || $month < 1 || $day < 1) {
    #handle bad dates
    $preform = "<p class=\"error\">Please provide a valid date after 46 BCE.</p>";
    
} else {

#convert to julian
    my $julian = Julian::convert_date($year, $month, $day);
#    print "j: $julian\n";

#convert to factors
    my @factors = Julian::factor($julian);
#    print (join ",", @factors) . "\n";

    my $ordinal = 0;
    my @ordinal_factors = ();
    if (@factors == 1){
	#get prime ordinal factors
	$ordinal = Julian::prime_index($julian);
	@ordinal_factors = Julian::factor($ordinal);
    }

#convert to searches
    my @searches = Julian::get_searches(join ",", @factors);

    my @sorted_searches;
    if (@factors == 1){
	@sorted_searches = sort {int(substr($b, 2)) <=> int(substr($a,2))} @searches;
    } else {
	@sorted_searches = sort {$b <=> $a} @searches;
    }

#get current/compare date
    my $compare_date;
    if (0){
	$compare_date = DateTime->today();
    }
#get info for range

#create response

#get html file and replace

#print join "\n", @searches;

    $results_text .= "<h2>Date: $year-$month-$day</h2>\n";
    $results_text .= "<h2>Julian day: $julian</h2>\n";
    $results_text .= "<h2>Julian factors: ".(join ", ", @factors). "</h2>\n";
    if ($ordinal > 0){
	$results_text .= "<h2>Julian prime ordinal factors: ".(join ", ", @ordinal_factors). "</h2>\n";
    }
    $results_text .= "<p>The following notable people have similar Julian factors. Similarity is highest with the first categories.</p>\n";
    $results_text .= "<ul>\n";
    my %matches;
    foreach my $search (@sorted_searches) {
	my @results;
	my $filename = Julian::get_filename($search, $data_dir);
	if (-r $filename){
	    my $this_result_text = "";
	    my ($search_factor, $search_remainder) = split ":", $search;
	    my @search_factors = Julian::factor($search_factor);
	    
	    if ($search_factor eq 'PRIME'){
		$this_result_text .= " <li>Prime:\n  <ul>\n";
	    } elsif ($search_factor =~ /^P/){
		if ($search_remainder eq 'PRIME'){
		    $this_result_text .= "<li>Prime ordinal that is prime:\n  <ul>\n";
		} else {
		    $this_result_text .= " <li>Prime ordinal factor of $search_remainder:\n  <ul>\n";
		}
	    } else {
		$this_result_text .= " <li>$search_factor (". (join ", ", @search_factors) .") and $search_remainder other factors:\n  <ul>\n";
	    }
	    open IN, $filename;
	    @results = <IN>;
	    close IN;
	    foreach my $result (@results){
		chomp $result;
		my ($name, $date, $factors) = split ", ", $result;
		my ($ryear, $rmonth, $rday) = $date =~ /(-?\d\d\d\d)-(\d\d)-(\d\d)/;
		if ($matches{$name}) {
		    next;
		} else {
		    $matches{$name} = 1;
		}
		my $text_name = $name;
		$text_name =~ s/_/ /g;
		$this_result_text .= "   <li>";
		if ($factors eq join ",", @factors){
		    $this_result_text .= "<b>Exact match:</b> ";
		} 
		$this_result_text .= "<a href=\"http://en.wikipedia.org/wiki/$name\">$text_name</a>, born on <a href=\"julianfactorpage.cgi?year=$ryear&month=$rmonth&day=$rday\">$date</a>, ";
		if ($factors =~ /,/){
		    $this_result_text .= "has the factors $factors.</li>\n";
		} else {
		    my $this_ordinal = Julian::prime_index($factors);
		    my @this_ordinal_factors = Julian::factor($this_ordinal);
		    $this_result_text .= "has the prime ordinal $this_ordinal ";
		    if (@this_ordinal_factors == 1){
			$this_result_text .= "which is itself prime.</li>\n";
		    } else {
			my $ordinal_factors = join ",", @this_ordinal_factors;
			$this_result_text .= "with factors $ordinal_factors.</li>\n";
		    }
		}
	    }
	    $this_result_text .= "  </ul>\n </li>\n";
	    if ($this_result_text =~ /born on/){
		$results_text .= $this_result_text;
	    }
	}
    }
    $results_text .= "</ul>";
}
my $html;
open IN, $html_file;
my @html = <IN>;
close IN;
$html = join "\n", @html;

#replacements:
#preform
$html =~ s/<!-- §PREFORM§ -->/$preform/;

#form
$html =~ s/id="year" value=""/id="year" value="$year"/;
$html =~ s/id="day" value=""/id="day" value="$day"/;
$html =~ s/option value="$month"/option value="$month" selected="selected"/;

#results
$html =~ s/<!-- §RESULTS§ -->/$results_text/;

print $html;

print "\n";
