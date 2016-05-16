#!/usr/bin/perl

use strict;
use Test;
push @INC, ".";

BEGIN { plan tests => 1 }
use Julian;

ok(Julian::convert_date(-44,3,15),1705426);
