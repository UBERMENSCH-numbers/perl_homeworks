#!/usr/bin/env perl
use 5.016;
use feature 'fc';


sub unsuffix($) {
	my $str= lc shift;
	if (index($str, "k") != -1) { substr($str, index($str, "k")) = ""; $str *= 1000 };
	if (index($str, "m") != -1) { substr($str, index($str, "m")) = ""; $str *= 1000000 };
	if (index($str, "g") != -1) { substr($str, index($str, "g")) = ""; $str *= 1000000000 };
	if (index($str, "t") != -1) { substr($str, index($str, "t")) = ""; $str *= 1000000000000 };
	return $str;
}

my @filenames = grep { !/-/ } @ARGV;
my @keys = map { split (//, substr $_, 1, length $_) } grep { /-/ } @ARGV;
my %keys_hash = map { $_ => 1 } @keys;
my $col_ind = ( grep {/\d/} @keys )[0];


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

if ($keys_hash{'k'}) {
	for (@data) {
		$_->[0] = (split /[ \t]/, $_->[0])[$col_ind-1] ;
	}
}

if ($keys_hash{'b'}) { $_->[0] =~ s/^\s+// for (@data) };

if ($keys_hash{'h'}) {
	@data = map { [ unsuffix($_->[0]) , $_->[1] ] } @data;
	$keys_hash{'n'} = 1;
}

my %uniq;
if ($keys_hash{'u'}) { @data = grep { !$uniq{$_->[0]}++ } @data };

my @data = sort {$a->[0] cmp $b->[0] } @data;

if ($keys_hash{'n'}) { @data = sort { $a->[0] <=> $b->[0]} @data };

if ($keys_hash{'M'}) {
	my %mon = (jan => 1, feb => 2, mar => 3, apr => 4, may => 5, jun => 6, jul => 7, aug => 8, sep => 9, oct => 10, nov => 11, dec => 12);
	@data = sort { $mon{ lc substr($a->[0], 0, 3) } <=> $mon{ lc substr($b->[0], 0, 3) }
		||
	$b->[0] cmp $a->[0] } @data;
}

if ($keys_hash{'r'}) { @data = reverse @data };

my @sorted = map { $_->[1] } @data;

if (!$keys_hash{'c'}) {
	print join("\n", @sorted);
} else {
	for my $i (0..$#sorted) {
		my $sort_i = $sorted[$i];
		my $input_i = $input[$i];
		if ($sort_i cmp $input_i) {
			print "disorder on line $i\n";
			last;
		}
	}
}


