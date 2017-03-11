#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';

if (scalar @ARGV != 2) {
    die "Usage:\n$0 foo.tar.gz /home/ubuntu\n";
}

my $SUB = shift;
my $DST = shift;

sub shell {
    my ($cmd) = @_;
    my $rv = system($cmd);
    die "cmd '$cmd' failed: $?" if $rv;
}

#
# Unpack to target directory.
#
say "Unpacking '$SUB' to '$DST' ...";

my $cmd = "";

if ($SUB =~ /\.tar\.gz$/i || $SUB =~ /\.tgz$/i) {
    $cmd = "tar xzvf";
}

if ($SUB =~ /\.zip$/i) {
    $cmd = "unzip";
}

system(qq{mkdir -p "$DST"});

if ($cmd eq "") {
    shell(qq{(cd "$DST" && cp "$SUB" .)});
    exit(0);
}

shell(qq{(cd "$DST" && $cmd "$SUB")});

my @top_items = `ls -F "$DST"`;
chomp @top_items;


#
# Unnest top level directory, if any.
#

if (scalar @top_items == 1) {
    my ($name, undef) = @top_items;
    $name =~ s/\/$//;
    shell(qq{(cd "$DST" && mv "$name"/* .)});
    shell(qq{(cd "$DST" && mv "$name" "_$name.$$")});
    say "Unnested top level directory '$name'.";
}

