#!/usr/bin/env perl
use strict;
use warnings;
use feature "say";
use Encode qw(decode);
use utf8;
use feature 'state';

binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');
@ARGV = map { decode("UTF-8", $_) } @ARGV;

sub get_args {
    my ($A, $B, $C, $pattern, $count, $ignore, $invert, $fixed, $line);

    for (@_) {
        state $prev = "";
        unless ($_ =~ /^-/ || $prev =~ /^-().*[ABC]$/) {
            $pattern = $_;
            last;
        }
        $prev = $_;
    }

    my $args = join " ", grep {$_ ne $pattern} @_;

    $A = ($args =~ /(?:A)(?: |=)?(\d*)/)[0];
    $B = ($args =~ /(?:B)(?: |=)?(\d*)/)[0];
    $C = ($args =~ /(?:C)(?: |=)?(\d*)/)[0];
    $count = ($args =~ /c/);
    $ignore = ($args =~ /i/);
    $invert = ($args =~ /v/);
    $fixed = ($args =~ /F/);
    $line = ($args =~ /n/);

    return ($A, $B, $C, $pattern, $count, $ignore, $invert, $fixed, $line);
 }

my ($after, $before, $context, $pattern, $count, $ignore, $invert, $fixed, $line) = get_args(@ARGV);

if ($context) {
    $after = defined $after ? $after : $context;
    $before = defined $before ? $before : $context;
}

my @input = <STDIN>;
s/\n// for @input;

my @data = map { [$_, 0] } @input;

if ($fixed) {
    $pattern = quotemeta $pattern;
}

if ($ignore) {
    @data = map { [ $_->[0], $_->[0] =~ /$pattern/i ? 1 : 0 ] } @data;
} else {
    @data = map { [ $_->[0], $_->[0] =~ /$pattern/ ? 1 : 0 ] } @data;
}

if ($invert) {
    @data = map { [$_->[0], !$_->[1]] } @data;
}

if ($count) {
    say scalar grep { $_->[1] == 1 } @data;
    exit 0;
}    


if ($after) {
    for my $i (0..$#data) {
        if ($data[$i]->[1] == 1) {
            my $r_bound = $i > $#data - $after  ? $#data : $i + $after; 
            @data[$i..$r_bound] = map { [$_->[0], $_->[1] == 1 ? 1 : 2] } @data[$i..$r_bound];
        }
    } 
}

if ($before) {
    for my $i (0..$#data) {
        if ($data[$i]->[1] == 1) {
            my $l_bound = $i < $before ? 0 : $i - $before;
            @data[$l_bound..$i] = map { [$_->[0], $_->[1] == 1 ? 1 : 2] } @data[$l_bound..$i];
        }
    } 
}

if ($line) {
    for my $i (0..$#data) {
        $data[$i]->[0] = $i + 1 . ($data[$i]->[1] == 1 ? ":" : "-") . $data[$i]->[0];
    }
}  


my @output = map { $_->[1] != 0 ? $_->[0] : () } @data;
print join "\n" , @output;
say "" if @output;
