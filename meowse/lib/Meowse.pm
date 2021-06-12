package Meowse;

use strict;
use warnings;
use Data::Dumper;
use Exporter 'import';
use Scalar::Util qw(looks_like_number);
our @EXPORT = qw(has new);


my %attr;

sub has {
    my ($name, %params) = @_;
    $attr{$name} = \%params;
}

sub new {
    my ($self, %params) = @_;
    # print Dumper(\%params);
    # print Dumper(\%attr);
    # for my $key (keys %params) {
    #     if ($attr{$_} && ((lc $attr{$_}{isa} eq lc ref %params{$_}) || ))
    # }
    return bless \%params, $self;
    
}

1;