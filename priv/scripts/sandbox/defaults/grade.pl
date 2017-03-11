#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';

say "# Running tests with 'make test'";
system("make test");

