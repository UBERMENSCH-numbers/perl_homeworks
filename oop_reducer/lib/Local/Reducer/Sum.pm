package Local::Reducer::Sum;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use parent "Local::Reducer";

sub reduce {
    my ($self, $row_obj) = @_;
    my $value = $row_obj->{$self->{field}};
    return 0 unless (looks_like_number($value));
    $self->{reduced} += $value;
}

1;