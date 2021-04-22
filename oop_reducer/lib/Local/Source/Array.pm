package Local::Source::Array;

use strict;
use warnings;

use parent 'Local::Source::SourceAbstract';

sub remain {
    my $self = shift;
    return @{$self->{array}} - $self->{pos} + 1;
}

sub next {
    my $self = shift;
    return $self->{pos} <= $#{$self->{array}} ? $self->{array}->[$self->{pos}++] : undef; 
}

1;