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
ok(Julian::is_prime(97), 1);
ok(Julian::is_prime(91), 0);
ok(Julian::get_gcd(91,28), 7);
ok(Julian::compare_dates(1972,12,7, 1973,6,12), "187:M");
ok(Julian::compare_dates(1944,7,11, 1802,2,26), "P:23");
