package Local::Row::Simple;

use strict;
use warnings;

use parent 'Local::Row::RowAbstract';

sub new {
    my $self = shift;
    my %hash = @_;
    my %data = map { $_->[0] => $_->[1] } map { [ m/:/ && (scalar split ":") == 2 ? split ":" : return undef ] } split ",", $hash{str};
    return bless \%data, $self; # ACHTUNG key:
}

1;