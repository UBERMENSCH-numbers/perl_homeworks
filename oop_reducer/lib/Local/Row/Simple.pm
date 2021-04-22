package Local::Row::Simple;

use strict;
use warnings;

use parent 'Local::Row::RowAbstract';

sub new {
    my $self = shift;
    my %hash = @_;
    my @data = split ",", $hash{str};
    for (@data) {
            $_ = [ split ":" ];
            return undef unless (@$_ == 2);
    }
    my %data = map { $_->[0] => $_->[1] } @data;
    return bless \%data, $self;
}

1;