#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;
use CGI::Capture::TieSTDIN      ();

my $str_lines = "line one\nline two";

my $str_chars = "abcdef";

my $str_both = $str_lines . "\n" . $str_chars;

tie *LINES, 'CGI::Capture::TieSTDIN', \$str_lines;
tie *CHARS, 'CGI::Capture::TieSTDIN', \$str_chars;
tie *BOTH,  'CGI::Capture::TieSTDIN', \$str_both;


my @lines;
for (1..3) {
    my $line = <LINES>;
    push @lines, $line;
}
is_deeply(\@lines,
    ["line one\n", "line two", undef],
    "line-based");


my @chars;
for (1..3) {
    my $chars;
    read(CHARS, $chars, 4);
    push @chars, $chars;
}
is_deeply(\@chars,
    ["abcd", "ef", undef],
    "char-based");


my @both;
for (1..2) {
    my $line = <BOTH>;
    push @both, $line;
}
for (1..3) {
    my $chars;
    read(BOTH, $chars, 4);
    push @both, $chars;
}
is_deeply(\@both,
    ["line one\n", "line two\n",
        "abcd", "ef", undef],
    "both line- and char-based");
