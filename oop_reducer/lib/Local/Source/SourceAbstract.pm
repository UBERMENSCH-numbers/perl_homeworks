package Local::Source::SourceAbstract;

use strict;
use warnings;

sub remain {
    my $self = shift;
    return $#{$self->{array}} - $self->{pos} + 1;
}

sub next {
    my $self = shift;
    return $self->{pos} <= $#{$self->{array}} ? $self->{array}->[$self->{pos}++] : undef; 
}

1;