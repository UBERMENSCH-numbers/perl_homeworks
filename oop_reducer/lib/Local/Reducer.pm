package Local::Reducer;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);


=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{reduced} = $hash{initial_value};
    return bless \%hash, $self;
}

sub reduced {
    my $self = shift;
    return $self->{reduced};
}

sub reduce_all {
    my $self = shift;
    return $self->reduce_n($self->{source}->remain());
}

1;
