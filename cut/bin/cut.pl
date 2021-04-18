#!/usr/bin/env perl

use strict;
use warnings;
use feature "say";
use Encode qw(encode decode);
use utf8;

binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');
@ARGV = map { decode("UTF-8", $_) } @ARGV;

sub get_args {
    my $args = join " ", @{+shift};

    my $delimiter = ($args =~ /(?:d) ?(.)/)[0];
    if (!defined $delimiter) {
        $delimiter = "\t";
    }

    my $separated = $args =~ /(?<!d )(?<!d)s/;
    my @fields = split ",", ($args =~ /(?:f ?((\d,?)+))/)[0];

    return (\@fields, $delimiter, $separated);
}

my ($fields, $delimiter, $separated) = get_args(\@ARGV);
my @fields = @$fields;

my @input = <STDIN>;
s/\n// for (@input);

if ($separated) {
    @input = grep { /\Q$delimiter/ } @input;
}

my @rows = map { [ split(quotemeta $delimiter , $_, -1) ] } @input;

my %inds = map { $_ - 1 => 1 } @fields;

for my $a (@rows) {
    next unless $#$a;
    $a = [ map { $inds{$_} ? $a->[$_] : () } 0..$#$a ];
}

@rows = map { join $delimiter, @$_ } @rows;
print join "\n", @rows;
say "" if (@rows);