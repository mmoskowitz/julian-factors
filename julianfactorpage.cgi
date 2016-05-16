#!/usr/bin/perl

push @INC, ".";
use Julian;
use strict;
use CGI;

#live
#my $data_dir = "/home/marc/public_html/math/julian/output-data";
#my $html_file = "/home/marc/public_html/math/julian/index.html";
#dev
my $data_dir = "output-data";
my $html_file = "index.html";

my $q = CGI->new;
print $q->header(-type=>'text/html', -charset=>'utf-8');

my $year = int($q->param('year'));
my $month = int($q->param('month'));
my $day = int($q->param('day'));

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

#convert to searches
    my @searches = Julian::get_searches(join ",", @factors);

#create response

#get html file and replace

#print join "\n", @searches;

    $results_text .= "<h2>Your Julian day: $julian</h2>\n";
    $results_text .= "<h2>Your Julian factors: ".(join ", ", @factors). "</h2>\n";
    $results_text .= "<p>The following notable people have similar Julian factors to you. Similarity is highest with the first categories.</p>\n";
    $results_text .= "<ul>";
    my %matches;
    foreach my $search (sort {$b <=> $a} @searches) {
	my @results;
	my $filename = Julian::get_filename($search, $data_dir);
	if (-r $filename){
	    my $this_result_text = "";
	    my ($search_factor, $search_remainder) = split ":", $search;
	    my @search_factors = Julian::factor($search_factor);
	    
	    if ($search_factor eq 'PRIME'){
	    $this_result_text .= " <li>Prime:\n  <ul>\n";
	    } else {
	    $this_result_text .= " <li>$search_factor (". (join ", ", @search_factors) .") and $search_remainder other factors:\n  <ul>\n";
	    }
	    open IN, $filename;
	    @results = <IN>;
	    close IN;
	    foreach my $result (@results){
		chomp $result;
		my ($name, $date, $factors) = split ", ", $result;
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
		$this_result_text .= "<a href=\"http://en.wikipedia.org/wiki/$name\">$text_name</a>, born on $date, has the factors $factors.</li>\n";
	    }
	    $this_result_text .= "  </ul>\n </li>\n";
	    if ($this_result_text =~ /has the factor/){
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
