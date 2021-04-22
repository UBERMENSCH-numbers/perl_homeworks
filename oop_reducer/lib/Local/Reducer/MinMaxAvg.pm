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

    if ($value < $self->{reduced}->get_min()) {
        $self->{reduced}->set_min($value); 
    }
    if ($value > $self->{reduced}->get_max()) {
        $self->{reduced}->set_max($value); 
    }
    $self->{reduced}->set_avg(($value + $self->{n} * $self->{reduced}->get_avg())/($self->{n}+1));
    $self->{n} ++;
}

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{reduced} = Local::Reducer::MinMaxAvgStorage->new(
        min => "+inf", 
        max => '-inf', 
        avg => 0
    );
    $hash{n} = 0;
    return bless \%hash, $self;
}

1;