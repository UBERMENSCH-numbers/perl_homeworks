package Local::Reducer::MinMaxAvg;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use parent 'Local::Reducer';
use Local::Reducer::MinMaxAvgStorage;

sub reduce {
    my ($self, $row_obj) = @_;
    my $value = $row_obj->{$self->{field}};

    return 0 unless (looks_like_number($value));
    
    $self->{min} = $value if ($value < $self->{min});
    $self->{max} = $value if ($value > $self->{max});
    $self->{avg} = ($value + $self->{n} * $self->{avg})/($self->{n}+1);
    $self->{n} ++;

    $self->{reduced} = Local::Reducer::MinMaxAvgStorage->new(
        min => $self->{min}, 
        max => $self->{max}, 
        avg => $self->{avg}
    );
}

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{min} = "+inf";
    $hash{max} = "-inf";
    ($hash{avg}, $hash{n}) = (0) x 2;
    return $self->SUPER::new(%hash);
}

1;