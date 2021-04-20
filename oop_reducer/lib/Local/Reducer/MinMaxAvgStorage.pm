package Local::Reducer::MinMaxAvgStorage;

use strict;
use warnings;
use Data::Dumper;
use Class::XSAccessor
    getters => {
        get_max => 'max',
        get_min => 'min',
        get_avg => 'avg'
    };

sub new {
    my $self = shift;
    my %hash = @_;
    return bless \%hash, $self;
}

1;