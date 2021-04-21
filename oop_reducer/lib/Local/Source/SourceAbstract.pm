package Local::Source::SourceAbstract;

use strict;
use warnings;

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{pos} = 0;
    return bless \%hash, $self;
}

sub remain {
    my $self = shift;
    return @{$self->{array}} - $self->{pos} + 1;
}

sub next {
    my $self = shift;
    return $self->{pos} <= $#{$self->{array}} ? $self->{array}->[$self->{pos}++] : undef; 
}

1;