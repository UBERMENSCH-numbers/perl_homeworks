#!/usr/bin/perl

use warnings;
use strict;
use feature "say";
use Data::Dumper;

use FindBin qw($RealBin);   # Directory in which the script lives
# use lib "/home/user/v.kotelnik/oop_reducer/lib/Local/Row";  # Where modules are, relative to $RealBin
use lib "/home/user/v.kotelnik/oop_reducer/lib/";  # Where modules are, relative to $RealBin
use Local::Reducer::Sum;
use Local::Row::Simple;
use Local::Source::Text;


my $reducer = Local::Reducer::Sum->new(
    source => Local::Source::Text->new(text =>"sended:1024,received:2048\nsended:0,received:0\ninvalid\nsended:2048,received:10240\n\nsended:2048,received:4096\nsended:foo,received:bar\n\n"),
    row_class => 'Local::Row::Simple',
    initial_value => 0,
);

say Dumper($reducer);