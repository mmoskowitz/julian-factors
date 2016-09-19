#!/usr/bin/perl

use strict;
use Test;
push @INC, ".";

BEGIN { plan tests => 9 }
use Julian;

ok(Julian::convert_date(-44,3,15),1705426);

ok(Julian::convert_date(1915,4,21), 2420609);
ok((Julian::factor(2420609))[0],(2420609));
ok((Julian::get_searches(join ',', Julian::factor(2420609)))[0],"P:PRIME");

my @searches = sort(Julian::get_searches(join ',', Julian::factor(2450250)));
ok($searches[181], "7425:all");

ok(Julian::is_prime(97), 1);
ok(Julian::is_prime(91), 0);

ok(Julian::get_gcd(91,28), 7);

ok(Julian::compare_dates(1972,12,7, 1973,6,12), "187:M");
ok(Julian::compare_dates(1944,7,11, 1802,2,26), "P:23");

ok(int(Julian::significance("1187:all")), 3);
ok((Julian::significance("1187:all", "true")), 4);
ok(int(Julian::significance("1187:2")), 4);
ok((Julian::significance("1187:2", "true")), 5);
