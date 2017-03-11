#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';
use strict;

use Test::Simple tests => 8;

sub run_fib {
    my ($xx) = @_;
    my $yy = `./fib $xx`;
    $yy =~ /fib\((\d+)\)\s+=\s+(\d+)/;
    ok($xx == $1, "printed $xx");
    return 0 + $2;
}

ok(run_fib(0)  == 0, "fib(0)");
ok(run_fib(1)  == 1, "fib(1)");
ok(run_fib(10) == 55, "fib(10)");
ok(run_fib(42) == 267914296, "fib(42)");

