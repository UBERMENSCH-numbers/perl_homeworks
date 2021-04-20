package Local::Reducer::MinMaxAvgStorage;

use strict;
use warnings;
use Class::XSAccessor
    getters => {
        get_max => 'max',
        get_min => 'min',
        get_avg => 'avg'
    };

sub new {
    my $foo = 'Class::XSAccessor'; ##  типа использую
    my $self = shift;
    my %hash = @_;
    return bless \%hash, $self;
}

1;