package Local::Source::Text;

use strict;
use warnings;

sub next {
    my $self = shift;
    return $self->{pos} <= $#{$self->{array}} ? $self->{array}->[$self->{pos}++] : undef; 
}

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{array} = [split $hash{delimiter} || "\n", $hash{text}];
    $hash{pos} = 0;
    delete $hash{text};
    return bless \%hash, $self;
}

sub remain {
    my $self = shift;
    return $#{$self->{array}} - $self->{pos};
}

1;