#!/usr/bin/env perl

use 5.016;

use strict;
use feature 'fc';

my @filenames = grep { !/-/ } @ARGV;
my @keys = map { split (//, substr $_, 1, length $_) } grep { /-/ } @ARGV;
my %keys_hash = map { $_ => 1 } @keys;

# if(%keys_hash{'M'} and %keys_hash{'n'}) { die "options '-Mn' are incompatible" };

# print "filenames : @filenames $#filenames \n";
# print "keys : @keys $#keys \n";


my @input;
if ($filenames[0]) {
    open(fh, '<', $filenames[0]) or die $!;
    push @input, <fh>;
} else {
    @input = <STDIN>;
}

chomp $_ for (@input);

my %uniq;
if ($keys_hash{'u'}) { @input = grep { !$uniq{$_}++ } @input };

# my @input = sort { fc $a cmp fc $b || $b cmp $a } @input;
my @input = sort @input;

if ($keys_hash{'n'}) { @input = sort {$a <=> $b} @input };


if ($keys_hash{'r'}) { @input = reverse @input };

print join("\n", @input);

