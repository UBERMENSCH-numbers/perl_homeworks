package Local::Reducer::MaxDiff;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use parent 'Local::Reducer';

sub reduce {
    my ($self, $row_obj) = @_;
    my $top_temp = $row_obj->{$self->{top}};
    my $bottom_temp = $row_obj->{$self->{bottom}};

    return 0 unless (
        defined $top_temp &&
        defined $bottom_temp && 
        looks_like_number($top_temp) && 
        looks_like_number($bottom_temp)
    );

    my $diff = $top_temp - $bottom_temp;

    $self->{reduced} = $diff > $self->{reduced} ? $diff : $self->{reduced}
}

1;