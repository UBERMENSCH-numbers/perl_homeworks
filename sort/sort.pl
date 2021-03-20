#!/usr/bin/env perl
use 5.016;
use feature 'fc';

my @filenames = grep { !/-/ } @ARGV;
my @keys = map { split (//, substr $_, 1, length $_) } grep { /-/ } @ARGV;
my %keys_hash = map { $_ => 1 } @keys;

if(%keys_hash{'M'} and %keys_hash{'n'}) { die "options '-Mn' are incompatible" };

my @input;
if ($filenames[0]) {
    open(fh, '<', $filenames[0]) or die $!;
    push @input, <fh>;
} else {
    @input = <STDIN>;
}

chomp $_ for (@input);
my @data = map {[$_, $_]} @input;

my %uniq;
if ($keys_hash{'u'}) { @data = grep { !$uniq{$_->[0]}++ } @data };

my @data = sort {$a->[0] cmp $b->[0]} @data;

if ($keys_hash{'n'}) { @data = sort { $a->[0] <=> $b->[0]} @data };

if ($keys_hash{'M'}) {
	my %mon = (jan => 1, feb => 2, mar => 3, apr => 4, may => 5, jun => 6, jul => 7, aug => 8, sep => 9, oct => 10, nov => 11, dec => 12);
	my %months = (january => 1, february => 2, march => 3, april => 4, may => 5, june => 6, july => 7, august => 8, september => 9, october => 10, november => 11, december => 12);
	@data = sort { ($mon{lc($a->[0])} or $months{lc($a->[0])}) <=> ($mon{lc($b->[0])} or $months{lc($b->[0])}) } @data;
}

if ($keys_hash{'r'}) { @data = reverse @data };

print join("\n", map {$_->[1]} @data);



