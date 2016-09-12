#!/usr/bin/perl

use strict;
use Test;
push @INC, ".";

BEGIN { plan tests => 1 }
use Julian;

ok(Julian::convert_date(-44,3,15),1705426);

ok(Julian::convert_date(1915,4,21), 2420609);
ok((Julian::factor(2420609))[0],(2420609));
ok((Julian::get_searches(join ',', Julian::factor(2420609)))[0],"P:PRIME")
