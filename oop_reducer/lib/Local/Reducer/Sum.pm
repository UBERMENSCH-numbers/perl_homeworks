package Local::Reducer::Sum;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use parent "Local::Reducer";

sub reduce_n {
    my ($self, $n) = @_;
    my $source = $self->{source};
    my $accum = 0;
    my $i = 0;
    while ($i < $n) {
        my $next_line = $source->next();
        last unless (defined $next_line);

        my $row_obj = $self->{row_class}->new(str => $next_line);
        if (defined $row_obj) {
            my $value = $row_obj->{$self->{field}};
            next unless (looks_like_number($value));
            $accum += $value;
        }
        $i ++;
    }
    $self->{reduced} += $accum;

}

1;