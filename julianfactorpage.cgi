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
    my $compare_date_string = $q->param('compare_date');
    my ($dy, $dm, $dd);
    if (($dy, $dm, $dd) = ($compare_date_string =~ /(-?\d+)-(\d+)-(\d+)/)){
	if ($dy < -46 || $dm > 12 || $dd > 31 || $dm < 1 || $dd < 1) {
	    #handle bad dates
	    $preform = "<p class=\"error\">Please compare a valid date after 46 BCE.</p>";
	    $compare_date_string = "";
	} else {
	    $compare_date = DateTime->new(
		year => $dy,
		month => $dm,
		day => $dd
		);
	}
    }
    if (!$compare_date){
	$compare_date = DateTime->today();
	$compare_date->subtract(days => 1); #account for time zones
    }

#get info for range
#35 days from compare_date
    my $show_o;
    if (@factors == 1){
	$show_o = "ordinal";
    }
    
    #create calendar nav
    my @nav_labels = qw(week month year decade century millennium);
    my @nav_units = qw(days months years years years years);
    my @nav_counts = qw(7 1 1 10 100 100);
    my @nav_tds = ();
    for (my $i; $i < @nav_labels; $i++){
	my $text = "   <td class='nav'>";
	my $nl = $nav_labels[$i];
	my $nav_date = DateTime->from_object(object => $compare_date);
	$nav_date->subtract($nav_units[$i] => $nav_counts[$i]);
	my $ny = $nav_date->ce_year();
	my $nm = $nav_date->month();
	my $nd = $nav_date->day();
	$text .= "<a href=\"julianfactorpage.cgi?year=$year&month=$month&day=$day&compare_date=$ny-$nm-$nd\" title=\"go back one $nl\">&#x2190;</a>";
	$text .= " ";
	$nav_date = DateTime->from_object(object => $compare_date);
	$nav_date->add($nav_units[$i] => $nav_counts[$i]);
	$ny = $nav_date->ce_year();
	$nm = $nav_date->month();
	$nd = $nav_date->day();
	$text .= "<a href=\"julianfactorpage.cgi?year=$year&month=$month&day=$day&compare_date=$ny-$nm-$nd\" title=\"go forward one $nl\">&#x2192;</a>";
	$text .= "<br/>$nl ";
	$text .= "</td>\n";
	push @nav_tds, $text;
    }

    my $ctable = "<table class='compares'>\n <caption>Greatest common $show_o factors:</caption>\n <tbody>\n  <tr>\n";
    my $nav_index = 0;
     for (my $i = 0; $i < $compare_date->day_of_week % 7; $i++){
	$ctable .= "   <td class='z'>&nbsp;</td>\n";
    }

    my ($cy,$cm,$cd,$cdow,$code);
    my ($show_p, $show_m);
    for (my $i = 0; $i < 35; $i++){
	$cy = $compare_date->ce_year();
	$cm = $compare_date->month();
	$cd = $compare_date->day();
	$cdow = $compare_date->day_of_week();
	$code = Julian::compare_dates(
	    $year, $month, $day, 
	    $cy, $cm, $cd);
	
	my $class = "";
	if ($code =~ /P/) {
	    $class .= "p ";
	    $show_p = 1;
	}
	if ($code =~ /M/) {
	    $class .= "m ";
	    $show_m = 1;
	} elsif ($code !~ /^(P:)?1(:M)?$/) {
	    $class .= "s "; #significant
	}
	$ctable .= "   <td class='$class'>$cy-$cm-$cd<br/>$code</td>\n";
	if ($cdow == 6){
	    if ($nav_index < @nav_tds){
		$ctable .= $nav_tds[$nav_index];
		$nav_index++;
	    }
	    $ctable .= "  </tr>\n";
	    $ctable .= "  <tr>\n";
	}

	$compare_date->add( days => 1);
    }
    for (my $i = ($compare_date->day_of_week() - 1) % 7; $i < 6; $i++){
	$ctable .= "   <td class='z'>&nbsp;</td>\n";
    }


    if ($compare_date->day_of_week != 7 && $nav_index < @nav_tds){
	$ctable .= $nav_tds[$nav_index];
	$nav_index++;
    }
    $ctable .= "  </tr>\n </tbody>\n";
    if ($show_m || $show_p || $compare_date->day_of_week() == 7){
	$ctable .=" <tfoot>\n  <tr>\n   <td colspan='7'>";
	if ($show_p){
	    $ctable .= "P indicates that the date is also prime.  ";
	}
	if ($show_m){
	    $ctable .= "M indicates that the date has the same number of $show_o factors.  ";
	}
	$ctable .="</td>\n";
	if ($nav_index < @nav_tds){
	    $ctable .= $nav_tds[$nav_index];
	    $nav_index++;
	}
	$ctable .="</tr>\n </tfoot>\n";
    }
    $ctable .= "</table>\n";

#create response

#get html file and replace

#print join "\n", @searches;

    $results_text .= "<h2>Date: $year-$month-$day</h2>\n";
    $results_text .= "<h2>Julian day: $julian</h2>\n";
    $results_text .= "<h2>Julian factors: ".(join ", ", @factors). "</h2>\n";
    if ($ordinal > 0){
	$results_text .= "<h2>Julian prime ordinal: $ordinal</h2>\n";
	$results_text .= "<h2>Julian prime ordinal factors: ".(join ", ", @ordinal_factors). "</h2>\n";
    }
    $results_text .= $ctable;
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
		#print $result;
		chomp $result;
		my ($name, $date, $rjulian, $factors, $rordinal, $rofactors, $rviews) = split ", ", $result;
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
		    $this_result_text .= "has the prime ordinal $rordinal ";
		    if ($rofactors !~ /,/){
			$this_result_text .= "which is itself prime.</li>\n";
		    } else {
			$this_result_text .= "with factors $rofactors.</li>\n";
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
