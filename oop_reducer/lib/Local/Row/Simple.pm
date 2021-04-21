package Local::Row::Simple;

use strict;
use warnings;

use parent 'Local::Row::RowAbstract';

sub new {
    my $self = shift;
    my %hash = @_;
    my @data = split ",", $hash{str};
    for (@data) {
            return undef if ((scalar split ":") != 2);
            $_ = [ split ":" ];
    }
    my %data = map { $_->[0] => $_->[1] } @data;
    return bless \%data, $self;
}

1;