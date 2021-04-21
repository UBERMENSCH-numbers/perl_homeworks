package Local::Reducer;

use strict;
use warnings;

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

sub reduce_n {
    my ($self, $n) = @_;
    my $source = $self->{source};
    my $i = 0;
    while ($i < $n) {
        my $next_line = $source->next();
        last unless (defined $next_line);

        my $row_obj = $self->{row_class}->new(str => $next_line);
        if (defined $row_obj) {
            $self->reduce($row_obj);
        }
        $i ++;
    }
    return $self->{reduced};
}

1;
